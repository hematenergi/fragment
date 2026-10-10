#!/usr/bin/env node
// Build a reproducible, oldest-record-first B-condition bundle from tracked knowledge files.
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

function argsOf(argv) {
  const values = {};
  for (let i = 0; i < argv.length; i += 1) {
    const key = argv[i];
    if (!key.startsWith('--') || argv[i + 1] === undefined) throw new Error('expected --name value arguments');
    values[key.slice(2)] = argv[++i];
  }
  return values;
}

function git(repo, argv) {
  const result = spawnSync('git', ['-C', repo, ...argv], {
    encoding: 'utf8', timeout: 30_000, maxBuffer: 10 * 1024 * 1024,
    env: Object.fromEntries(Object.entries(process.env).filter(([name]) =>
      !['GEMINI_API_KEY', 'GOOGLE_API_KEY', 'GH_MODELS_TOKEN', 'OPENAI_API_KEY'].includes(name))),
  });
  if (result.status !== 0) throw new Error('git metadata lookup failed');
  return result.stdout.trim();
}

function pathIsKnowledge(relative) {
  const prefixes = ['decisions/', 'lessons/', 'plans/', 'docs/decisions/', 'docs/lessons/', 'docs/plans/'];
  return prefixes.some((prefix) => relative.startsWith(prefix)) && relative.toLowerCase().endsWith('.md');
}

function main() {
  const args = argsOf(process.argv.slice(2));
  const repo = fs.realpathSync(args.repo ?? '');
  const out = path.resolve(args.out ?? '');
  const manifestPath = path.resolve(args.manifest ?? '');
  const dropOldest = Number(args['drop-oldest']);
  if (!Number.isSafeInteger(dropOldest) || dropOldest < 0) throw new Error('--drop-oldest must be a non-negative integer');
  if (out === manifestPath) throw new Error('bundle and manifest paths must differ');
  if (fs.existsSync(out) || fs.existsSync(manifestPath)) throw new Error('refusing to replace an existing bundle or manifest');

  const commit = git(repo, ['rev-parse', 'HEAD']);
  const tracked = git(repo, ['ls-files', '-z']).split('\0').filter(Boolean).filter(pathIsKnowledge);
  const records = tracked.map((relative) => {
    const absolute = path.join(repo, relative);
    const stat = fs.lstatSync(absolute);
    if (!stat.isFile() || stat.isSymbolicLink()) throw new Error('knowledge inputs must be regular tracked files');
    const content = fs.readFileSync(absolute, 'utf8');
    const addedDate = git(repo, ['log', '--follow', '--diff-filter=A', '-1', '--format=%cs', 'HEAD', '--', relative]) || '9999-12-31';
    return {
      path: relative,
      addedDate,
      bytes: Buffer.byteLength(content, 'utf8'),
      sha256: crypto.createHash('sha256').update(content).digest('hex'),
      content,
    };
  }).sort((a, b) => (a.addedDate < b.addedDate ? -1 : a.addedDate > b.addedDate ? 1 : 0)
    || (a.path < b.path ? -1 : a.path > b.path ? 1 : 0));
  if (records.length === 0) throw new Error('no tracked Markdown records found under decisions, lessons, or plans');

  const preamble = 'The following repository knowledge records are included in their original text. They are ordered from oldest to newest and may contain historical or superseded information.\n';
  const render = (items) => preamble + items.map((record) =>
    '\n\n[Source: ' + record.path + ']\n' + record.content.trim() + '\n').join('');
  if (dropOldest >= records.length) throw new Error('--drop-oldest must retain at least one knowledge record');
  const included = records.slice(dropOldest);
  const bundle = render(included);
  fs.mkdirSync(path.dirname(out), { recursive: true, mode: 0o700 });
  fs.mkdirSync(path.dirname(manifestPath), { recursive: true, mode: 0o700 });
  fs.writeFileSync(out, bundle, { mode: 0o600, flag: 'wx' });
  const includedSet = new Set(included.map((record) => record.path));
  const manifest = {
    schemaVersion: 1,
    repoCommit: commit,
    dateRule: 'first Git add date, then repository-relative path',
    trimRule: 'remove the specified number of oldest whole files by first Git add date, then path',
    dropOldest,
    bundleChars: bundle.length,
    bundleSha256: crypto.createHash('sha256').update(bundle).digest('hex'),
    includedFiles: records.filter((record) => includedSet.has(record.path)).map(({ path: p, addedDate, bytes, sha256 }) => ({ path: p, addedDate, bytes, sha256 })),
    omittedFiles: records.filter((record) => !includedSet.has(record.path)).map(({ path: p, addedDate, bytes, sha256 }) => ({ path: p, addedDate, bytes, sha256 })),
  };
  fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2) + '\n', { mode: 0o600, flag: 'wx' });
  process.stdout.write(JSON.stringify({
    repoCommit: commit, trackedRecords: records.length, includedRecords: included.length,
    omittedRecords: records.length - included.length, dropOldest, bundleChars: bundle.length,
    bundleSha256: manifest.bundleSha256, manifestPath,
  }) + '\n');
}

try { main(); }
catch (error) {
  process.stderr.write('Bundle preparation stopped: ' + error.message + '\n');
  process.exitCode = 2;
}
