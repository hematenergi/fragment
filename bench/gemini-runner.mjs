#!/usr/bin/env node
// Local benchmark harness. API credentials stay in memory and are never logged.
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const MODEL = 'gemini-3.8-flash';
const API_ROOT = 'https://generativelanguage.googleapis.com/v1beta/models';
const IMAGE = 'sha256:1dc5bcac894ca20e094cb9c71c626fc3cc350d005dbdc853aae46c040d4f45b9';
const MAX_CONTEXT = 1_048_576;
const CALIBRATION_CAP = 10_000_000;
const API_SPACING_MS = 15_000;
const REQUEST_TIMEOUT_MS = 120_000;
const COMMAND_TIMEOUT_MS = 300_000;
const MAX_TOOL_OUTPUT_CHARS = 12_000;
const MAX_READ_CHARS = 40_000;
const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const FORBIDDEN_COMPONENTS = new Set(['.git', 'node_modules']);
const SAFE_ENV_EXAMPLES = new Set(['.env.example', '.env.sample', '.env.template']);

const toolDeclarations = [
  {
    name: 'list_dir',
    description: 'List sorted entries in a repository directory.',
    parametersJsonSchema: {
      type: 'object', properties: { path: { type: 'string' } },
      required: ['path'], additionalProperties: false,
    },
  },
  {
    name: 'read_file',
    description: 'Read a UTF-8 repository file, optionally by one-based line range.',
    parametersJsonSchema: {
      type: 'object',
      properties: {
        path: { type: 'string' }, start_line: { type: 'integer', minimum: 1 },
        end_line: { type: 'integer', minimum: 1 },
      },
      required: ['path'], additionalProperties: false,
    },
  },
  {
    name: 'search_text',
    description: 'Search repository text using a fixed-string query.',
    parametersJsonSchema: {
      type: 'object', properties: { query: { type: 'string' }, path: { type: 'string' } },
      required: ['query', 'path'], additionalProperties: false,
    },
  },
  {
    name: 'write_file',
    description: 'Write UTF-8 content to a file under the repository; parent directory must exist.',
    parametersJsonSchema: {
      type: 'object', properties: { path: { type: 'string' }, content: { type: 'string' } },
      required: ['path', 'content'], additionalProperties: false,
    },
  },
  {
    name: 'edit_file',
    description: 'Replace one exact unique text span in a repository file.',
    parametersJsonSchema: {
      type: 'object',
      properties: {
        path: { type: 'string' }, old_text: { type: 'string' }, new_text: { type: 'string' },
      },
      required: ['path', 'old_text', 'new_text'], additionalProperties: false,
    },
  },
  {
    name: 'run_command',
    description: 'Run one allowlisted argv inside the isolated repository container. No shell syntax.',
    parametersJsonSchema: {
      type: 'object', properties: { argv: { type: 'array', items: { type: 'string' } } },
      required: ['argv'], additionalProperties: false,
    },
  },
];

class InfraFailure extends Error {
  constructor(code, status = null) {
    super(code);
    this.code = code;
    this.status = status;
  }
}

function parseDotEnv(text) {
  const values = {};
  for (const raw of text.split(/\r?\n/)) {
    const line = raw.trim();
    if (!line || line.startsWith('#')) continue;
    const match = /^(?:export\s+)?([A-Z0-9_]+)=(.*)$/.exec(line);
    if (!match) continue;
    const [, name] = match;
    if (!['GEMINI_API_KEY', 'GEMINI_MODEL'].includes(name)) continue;
    let value = match[2].trim();
    if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    }
    values[name] = value;
  }
  return values;
}

function parseArgs(argv) {
  const out = { positional: [] };
  for (let i = 0; i < argv.length; i += 1) {
    const item = argv[i];
    if (!item.startsWith('--')) { out.positional.push(item); continue; }
    const key = item.slice(2);
    if (key === 'self-test') { out.self_test = true; continue; }
    if (key === 'edit-path') {
      const value = argv[++i];
      if (value === undefined) throw new Error('missing value for --edit-path');
      (out.editable_paths ??= []).push(value);
      continue;
    }
    const value = argv[++i];
    if (value === undefined) throw new Error(`missing value for --${key}`);
    out[key.replaceAll('-', '_')] = value;
  }
  return out;
}

function runFile(command, args, options = {}) {
  const env = { ...process.env };
  for (const name of ['GEMINI_API_KEY', 'GOOGLE_API_KEY', 'GH_MODELS_TOKEN', 'OPENAI_API_KEY']) delete env[name];
  const result = spawnSync(command, args, {
    cwd: options.cwd,
    env,
    encoding: 'utf8',
    timeout: options.timeout ?? COMMAND_TIMEOUT_MS,
    maxBuffer: 10 * 1024 * 1024,
  });
  return result;
}

function validatePath(repoRoot, relativePath, { allowMissing = false } = {}) {
  if (typeof relativePath !== 'string' || !relativePath || relativePath.includes('\0')) throw new Error('invalid repository path');
  if (path.isAbsolute(relativePath)) throw new Error('repository tools require relative paths');
  const parts = relativePath.split(/[\\/]+/).filter(Boolean);
  if (parts.some((part) => part === '..' || FORBIDDEN_COMPONENTS.has(part) || /^\.env(?:\.|$)/i.test(part))) {
    throw new Error('path is outside the tool allowlist');
  }
  const rootReal = fs.realpathSync(repoRoot);
  const target = path.resolve(rootReal, relativePath);
  if (target !== rootReal && !target.startsWith(`${rootReal}${path.sep}`)) throw new Error('path escaped repository');
  let checked;
  try { checked = fs.realpathSync(target); }
  catch (error) {
    if (!allowMissing || error.code !== 'ENOENT') throw new Error('repository path is missing or unsafe');
    checked = fs.realpathSync(path.dirname(target));
  }
  if (checked !== rootReal && !checked.startsWith(`${rootReal}${path.sep}`)) throw new Error('symlink escaped repository');
  return target;
}

function canonicalRepoPath(repoRoot, relativePath) {
  const rootReal = fs.realpathSync(repoRoot);
  const target = validatePath(rootReal, relativePath, { allowMissing: true });
  const canonicalTarget = fs.existsSync(target) ? fs.realpathSync(target) : target;
  const relative = path.relative(rootReal, canonicalTarget).split(path.sep).join('/');
  if (!relative) throw new Error('repository root is not an editable file');
  return relative;
}

function isCredentialShapedPath(name) {
  const basename = path.basename(name).toLowerCase();
  const envFile = /^\.env(?:\.|$)/i.test(basename) && !SAFE_ENV_EXAMPLES.has(basename);
  return envFile || /(^|\/)(?:secrets?|credentials?)(\/|$)/i.test(name);
}

function assertEditable(context, relativePath) {
  const canonical = canonicalRepoPath(context.repoRoot, relativePath);
  if (!context.editablePaths.has(canonical)) throw new Error('file is not in the run-specific edit allowlist');
  return canonical;
}

function tail(text, limit = MAX_TOOL_OUTPUT_CHARS) {
  if (text.length <= limit) return text;
  return `[earlier output omitted; last ${limit} characters follow]\n${text.slice(-limit)}`;
}

function listDir(repoRoot, args) {
  const target = validatePath(repoRoot, args.path);
  const entries = fs.readdirSync(target, { withFileTypes: true })
    .filter((entry) => !FORBIDDEN_COMPONENTS.has(entry.name) && !/^\.env(?:\.|$)/i.test(entry.name))
    .map((entry) => `${entry.isDirectory() ? 'dir' : entry.isFile() ? 'file' : 'other'}\t${entry.name}`)
    .sort((a, b) => a.localeCompare(b));
  return tail(entries.slice(0, 500).join('\n') || '(empty directory)');
}

function readFile(repoRoot, args) {
  const target = validatePath(repoRoot, args.path);
  const data = fs.readFileSync(target);
  if (data.includes(0)) throw new Error('binary files are not readable by this tool');
  const text = data.toString('utf8');
  if (args.start_line !== undefined || args.end_line !== undefined) {
    const lines = text.split(/\r?\n/);
    const start = Number(args.start_line ?? 1);
    const end = Number(args.end_line ?? lines.length);
    if (!Number.isInteger(start) || !Number.isInteger(end) || start < 1 || end < start) throw new Error('invalid line range');
    return tail(lines.slice(start - 1, end).join('\n'));
  }
  if (text.length <= MAX_READ_CHARS) return text;
  return `${text.slice(0, MAX_READ_CHARS)}\n[truncated; request a line range to continue]`;
}

function searchText(repoRoot, args) {
  const target = validatePath(repoRoot, args.path);
  if (typeof args.query !== 'string' || !args.query) throw new Error('query must not be empty');
  const result = runFile('rg', [
    '--fixed-strings', '--line-number', '--no-heading', '--color', 'never', '--sort', 'path',
    '--max-count', '100', '--glob', '!**/.env*', '--glob', '!**/node_modules/**', '--glob', '!**/.git/**',
    '--', args.query, target,
  ], { cwd: repoRoot });
  if (result.error) throw new Error('search command unavailable');
  if (result.status !== 0 && result.status !== 1) throw new Error('search command failed');
  return tail(result.stdout || '(no matches)');
}

function writeFile(repoRoot, args, context) {
  assertEditable(context, args.path);
  const target = validatePath(repoRoot, args.path, { allowMissing: true });
  if (!fs.existsSync(path.dirname(target))) throw new Error('parent directory must already exist');
  if (typeof args.content !== 'string') throw new Error('content must be text');
  fs.writeFileSync(target, args.content, { encoding: 'utf8', flag: 'w', mode: 0o600 });
  return `wrote ${args.content.length} characters to ${args.path}`;
}

function editFile(repoRoot, args, context) {
  assertEditable(context, args.path);
  const target = validatePath(repoRoot, args.path);
  const text = fs.readFileSync(target, 'utf8');
  const count = text.split(args.old_text).length - 1;
  if (!args.old_text || count !== 1) throw new Error(`expected one exact old_text match; found ${count}`);
  fs.writeFileSync(target, text.replace(args.old_text, args.new_text), 'utf8');
  return `updated one exact span in ${args.path}`;
}

function allowedCommand(argv) {
  if (!Array.isArray(argv) || argv.length === 0 || argv.some((part) => typeof part !== 'string' || part.includes('\0'))) return false;
  const exact = [
    ['npm', 'test'], ['npm', 'run', 'build'], ['npm', 'run', 'test:integration'],
    ['npm', 'run', 'test:unit'], ['npm', 'run', 'test:syntax'],
    ['git', 'status', '--short'], ['git', 'diff', '--check'], ['git', 'diff', '--stat'],
    ['node', '--test', '--experimental-test-module-mocks', 'tests/integration/stranded-close-executor.test.js'],
  ];
  if (exact.some((candidate) => candidate.length === argv.length && candidate.every((part, index) => part === argv[index]))) return true;
  if (argv[0] === 'bash' && argv[1] === 'scripts/recall.sh' && argv.length >= 3 && argv.every((part) => !part.startsWith('/'))) return true;
  if (argv[0] === 'bash' && argv[1] === 'scripts/load-context.sh' && argv[2] === '--budget'
      && /^[1-9][0-9]*$/.test(argv[3] ?? '') && argv.length >= 5 && argv.every((part) => !part.startsWith('/'))) return true;
  return false;
}

function dockerExec(containerId, argv, runtime) {
  if (!allowedCommand(argv)) throw new Error('command is not in the benchmark allowlist');
  const pathValue = runtime === 'node22'
    ? '/opt/node-22.13.1/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
    : '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin';
  const result = runFile('docker', ['exec', containerId, 'env', `PATH=${pathValue}`, ...argv], { timeout: COMMAND_TIMEOUT_MS });
  if (result.error?.code === 'ETIMEDOUT') return { exitCode: 124, output: 'command timed out after 300 seconds' };
  if (result.error) throw new Error('container command could not start');
  return { exitCode: result.status ?? 1, output: tail(`${result.stdout ?? ''}${result.stderr ?? ''}`) };
}

function executeTool(name, args, context) {
  try {
    let result;
    switch (name) {
      case 'list_dir': result = listDir(context.repoRoot, args); break;
      case 'read_file': result = readFile(context.repoRoot, args); break;
      case 'search_text': result = searchText(context.repoRoot, args); break;
      case 'write_file': result = writeFile(context.repoRoot, args, context); break;
      case 'edit_file': result = editFile(context.repoRoot, args, context); break;
      case 'run_command': result = dockerExec(context.containerId, args.argv, context.runtime); break;
      default: throw new Error('unknown tool');
    }
    return { ok: true, result };
  } catch (error) {
    return { ok: false, error: String(error.message).slice(0, 500) };
  }
}

function appendLog(logPath, event) {
  fs.appendFileSync(logPath, `${JSON.stringify({ timestamp: new Date().toISOString(), ...event })}\n`, { mode: 0o600 });
}

function gitStatus(repoRoot) {
  const status = runFile('git', ['-C', repoRoot, 'status', '--porcelain', '--untracked-files=all']);
  if (status.status !== 0) throw new Error('could not inspect prepared workspace');
  return status.stdout.trim().split(/\r?\n/).filter(Boolean).map((line) => line.slice(3));
}

function assertCleanWorkspace(repoRoot) {
  const listed = runFile('git', ['-C', repoRoot, 'ls-files', '-z']);
  if (listed.status !== 0) throw new Error('workspace must be a Git checkout');
  const tracked = listed.stdout.split('\0').filter(Boolean);
  if (tracked.some(isCredentialShapedPath)) {
    throw new Error('workspace contains a tracked credential-shaped path');
  }
  if (fs.existsSync(path.join(repoRoot, '.env'))) throw new Error('workspace contains a local .env file');
  if (gitStatus(repoRoot).length) throw new Error('workspace must be clean before a run');
}

function createContainer(repoRoot, depsRoot, runtime) {
  const mounts = ['--mount', `type=bind,source=${repoRoot},target=/workspace`];
  if (depsRoot) mounts.push('--mount', `type=bind,source=${depsRoot},target=/workspace/node_modules,readonly`);
  const created = runFile('docker', [
    'create', '--platform=linux/arm64', '--network=none', ...mounts, '--workdir=/workspace', IMAGE,
    'bash', '-lc', 'sleep infinity',
  ]);
  if (created.status !== 0 || !created.stdout.trim()) throw new InfraFailure('CONTAINER_CREATE_FAILED');
  const id = created.stdout.trim().split(/\s+/).at(-1);
  const started = runFile('docker', ['start', id]);
  if (started.status !== 0) {
    runFile('docker', ['rm', '--force', id]);
    throw new InfraFailure('CONTAINER_START_FAILED');
  }
  return id;
}

async function pace(state) {
  if (state.lastApiAt) {
    const remaining = API_SPACING_MS - (Date.now() - state.lastApiAt);
    if (remaining > 0) await new Promise((resolve) => setTimeout(resolve, remaining));
  }
  state.lastApiAt = Date.now();
}

async function apiCall(method, body, key, state, logPath, meta) {
  await pace(state);
  const url = `${API_ROOT}/${MODEL}:${method}`;
  appendLog(logPath, { type: 'api_request', method, body, ...meta });
  const startedAt = Date.now();
  let response;
  try {
    response = await fetch(url, {
      method: 'POST',
      headers: { 'content-type': 'application/json', 'x-goog-api-key': key },
      body: JSON.stringify(body),
      signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
    });
  } catch (error) {
    const code = error.name === 'TimeoutError' || error.name === 'AbortError' ? 'REQUEST_TIMEOUT' : 'NETWORK_ERROR';
    appendLog(logPath, { type: 'api_failure', method, code, durationMs: Date.now() - startedAt, ...meta });
    throw new InfraFailure(code);
  }
  const text = await response.text();
  let json;
  try { json = JSON.parse(text); } catch { json = { rawText: text.slice(0, 2000) }; }
  appendLog(logPath, {
    type: 'api_response', method, status: response.status, durationMs: Date.now() - startedAt,
    response: json, rateLimitHeaders: Object.fromEntries([...response.headers.entries()].filter(([name]) => /^(?:x-ratelimit-[a-z0-9-]+|ratelimit(?:-[a-z0-9-]+)?|retry-after)$/i.test(name))),
    ...meta,
  });
  if (!response.ok) throw new InfraFailure(`HTTP_${response.status}`, response.status);
  return json;
}

function buildRequest(systemText, contents) {
  return {
    systemInstruction: { parts: [{ text: systemText }] },
    contents,
    tools: [{ functionDeclarations: toolDeclarations }],
    toolConfig: { functionCallingConfig: { mode: 'AUTO' } },
    generationConfig: { thinkingConfig: { thinkingLevel: 'low' } },
  };
}

function responseText(candidate) {
  return (candidate?.content?.parts ?? []).filter((part) => typeof part.text === 'string').map((part) => part.text).join('\n').trim();
}

function functionCalls(candidate) {
  return (candidate?.content?.parts ?? []).filter((part) => part.functionCall).map((part) => part.functionCall);
}

async function generate(contents, state, context, budget, stage) {
  const request = buildRequest(context.systemText, contents);
  const countResponse = await apiCall('countTokens', { generateContentRequest: request }, context.apiKey, state, context.logPath, { stage });
  const estimate = countResponse.totalTokens;
  if (!Number.isInteger(estimate) || estimate < 0) throw new InfraFailure('TOKEN_PREFLIGHT_INVALID');
  if (estimate > MAX_CONTEXT) throw new InfraFailure('SINGLE_REQUEST_CONTEXT_LIMIT');
  if (stage === 'onboarding' && context.generations === 0 && estimate > Math.floor(MAX_CONTEXT * 0.8)) {
    throw new InfraFailure('ONBOARDING_TRUNCATION_REQUIRED');
  }
  if (context.inputTokens + estimate > budget) return { budgetReached: true, preflightTokens: estimate };

  const response = await apiCall('generateContent', request, context.apiKey, state, context.logPath, { stage, preflightTokens: estimate });
  const modelVersion = response.modelVersion;
  if (modelVersion !== MODEL) throw new InfraFailure('MODEL_VERSION_MISMATCH');
  const usage = response.usageMetadata;
  if (!Number.isInteger(usage?.promptTokenCount) || !Number.isInteger(usage?.candidatesTokenCount)
      || !Number.isInteger(usage?.totalTokenCount)) throw new InfraFailure('USAGE_METADATA_MISSING');
  const candidate = response.candidates?.[0];
  if (!candidate?.content) {
    const finishReason = candidate?.finishReason;
    if (['SAFETY', 'RECITATION', 'BLOCKLIST', 'PROHIBITED_CONTENT', 'SPII'].includes(finishReason)) {
      throw new InfraFailure('CONTENT_REFUSAL');
    }
    throw new InfraFailure('CANDIDATE_CONTENT_MISSING');
  }
  context.inputTokens += usage.promptTokenCount;
  context.outputTokens += usage.candidatesTokenCount;
  if (Number.isInteger(usage.thoughtsTokenCount)) context.thoughtsTokens += usage.thoughtsTokenCount;
  else context.thoughtsMissing += 1;
  context.generations += 1;
  context.modelVersions.add(modelVersion);
  context.usageMismatches += usage.promptTokenCount === estimate ? 0 : 1;
  return { candidate, usage, modelVersion, preflightTokens: estimate, budgetReached: false };
}

async function processStage(contents, context, budget, stage, stopWhenReady = false) {
  while (true) {
    if (stage === 'onboarding' && context.inputTokens >= budget / 2) return { stopped: 'half-budget' };
    if (stage !== 'onboarding' && context.inputTokens >= budget) return { stopped: 'budget' };
    const inputCap = stage === 'onboarding' ? Math.floor(budget / 2) : budget;
    const result = await generate(contents, context.state, context, inputCap, stage);
    if (result.budgetReached) return { stopped: 'budget' };
    if (stage === 'onboarding' && context.inputTokens >= budget / 2) return { stopped: 'half-budget' };
    if (stage !== 'onboarding' && context.inputTokens > budget) return { stopped: 'budget', actualOverrun: true };
    const candidate = result.candidate;
    const text = responseText(candidate);
    const calls = functionCalls(candidate);
    if (stopWhenReady && !calls.length && text === 'READY') return { stopped: 'ready' };
    if (calls.length === 0) return { stopped: 'turn-complete', finalText: text };
    contents.push(candidate.content);
    const functionParts = [];
    for (const call of calls) {
      const toolResult = executeTool(call.name, call.args ?? {}, context);
      appendLog(context.logPath, { type: 'tool_call', stage, name: call.name, args: call.args ?? {}, result: toolResult });
      const responsePart = { name: call.name, response: toolResult };
      if (call.id) responsePart.id = call.id;
      functionParts.push({ functionResponse: responsePart });
    }
    contents.push({ role: 'user', parts: functionParts });
  }
}

async function runBenchmark(args) {
  const runId = args.run_id;
  if (!/^[A-Za-z0-9_-]{1,80}$/.test(runId ?? '')) throw new Error('run id must use letters, digits, _ or -');
  const repoRoot = fs.realpathSync(args.repo);
  const depsRoot = args.deps ? fs.realpathSync(args.deps) : null;
  const privateDir = fs.realpathSync(args.private_dir);
  const systemText = fs.readFileSync(args.system, 'utf8');
  const onboardingText = fs.readFileSync(args.onboarding, 'utf8');
  const questionsText = fs.readFileSync(args.questions, 'utf8');
  const taskText = fs.readFileSync(args.task, 'utf8');
  const budget = args.budget ? Number(args.budget) : CALIBRATION_CAP;
  const runtime = args.runtime ?? 'node22';
  if (!Number.isSafeInteger(budget) || budget < 1) throw new Error('budget must be a positive integer');
  if (!['node22', 'node24'].includes(runtime)) throw new Error('runtime must be node22 or node24');
  if (!path.isAbsolute(privateDir) || privateDir === repoRoot || privateDir.startsWith(`${repoRoot}${path.sep}`)) throw new Error('private logs must be outside the repository');
  if (depsRoot && (depsRoot === repoRoot || depsRoot.startsWith(`${repoRoot}${path.sep}`))) throw new Error('dependency mount must be outside the run workspace');
  assertCleanWorkspace(repoRoot);
  if (depsRoot && !fs.statSync(depsRoot).isDirectory()) throw new Error('dependency mount must be a directory');
  const editablePaths = new Set((args.editable_paths ?? []).map((value) => canonicalRepoPath(repoRoot, value)));
  const logPath = path.join(privateDir, `${runId}.jsonl`);
  if (fs.existsSync(logPath)) throw new Error('run log already exists; use a new attempt id');
  fs.mkdirSync(privateDir, { recursive: true, mode: 0o700 });
  fs.chmodSync(privateDir, 0o700);
  fs.writeFileSync(logPath, '', { mode: 0o600, flag: 'wx' });
  const configText = fs.readFileSync(path.join(ROOT, 'bench', '.env'), 'utf8');
  const config = parseDotEnv(configText);
  if (!config.GEMINI_API_KEY || /^(PASTE_|PLACEHOLDER|\[.*\])/i.test(config.GEMINI_API_KEY)) throw new Error('Gemini API key is missing or a placeholder');
  if (config.GEMINI_MODEL !== MODEL) throw new Error('configured Gemini model does not match the frozen model');

  const context = {
    apiKey: config.GEMINI_API_KEY, systemText, logPath, repoRoot, runtime, editablePaths,
    inputTokens: 0, outputTokens: 0, thoughtsTokens: 0, thoughtsMissing: 0,
    generations: 0, modelVersions: new Set(), usageMismatches: 0,
    containerId: null, state: { lastApiAt: 0 },
  };
  appendLog(logPath, {
    type: 'run_start', runId, model: MODEL, budget, runtime, image: IMAGE, editablePaths: [...editablePaths],
    repoCommit: runFile('git', ['-C', repoRoot, 'rev-parse', 'HEAD']).stdout.trim(),
  });
  try {
    context.containerId = createContainer(repoRoot, depsRoot, runtime);
    const contents = [{ role: 'user', parts: [{ text: onboardingText }] }];
    const onboardingResult = await processStage(contents, context, budget, 'onboarding', true);
    appendLog(logPath, { type: 'stage_end', stage: 'onboarding', reason: onboardingResult.stopped, finalText: onboardingResult.finalText ?? null });

    let quizResult;
    if (context.inputTokens >= budget) quizResult = { stopped: 'budget' };
    else {
      contents.push({ role: 'user', parts: [{ text: questionsText }] });
      quizResult = await processStage(contents, context, budget, 'quiz');
    }
    appendLog(logPath, { type: 'stage_end', stage: 'quiz', reason: quizResult.stopped, finalText: quizResult.finalText ?? null });

    let taskResult;
    if (quizResult.stopped === 'budget') taskResult = { stopped: 'budget' };
    else {
      contents.push({ role: 'user', parts: [{ text: taskText }] });
      taskResult = await processStage(contents, context, budget, 'task');
    }
    appendLog(logPath, { type: 'stage_end', stage: 'task', reason: taskResult.stopped, finalText: taskResult.finalText ?? null });
    const summary = {
      runId, status: taskResult.stopped === 'budget' || context.inputTokens > budget ? 'budget-exhausted' : 'complete',
      inputTokens: context.inputTokens, outputTokens: context.outputTokens,
      thoughtsTokensReported: context.thoughtsTokens, responsesMissingThoughts: context.thoughtsMissing,
      generations: context.generations, modelVersions: [...context.modelVersions],
      usageMismatches: context.usageMismatches, onboardingStop: onboardingResult.stopped,
      quizStop: quizResult.stopped, taskStop: taskResult.stopped, privateLog: logPath,
    };
    appendLog(logPath, { type: 'run_end', ...summary });
    process.stdout.write(`${JSON.stringify(summary)}\n`);
    return summary;
  } catch (error) {
    const code = error instanceof InfraFailure ? error.code : 'LOCAL_RUN_ERROR';
    appendLog(logPath, { type: 'run_end', runId, status: 'infrastructure-incomplete', code, httpStatus: error.status ?? null });
    process.stderr.write(`Run incomplete: ${code}${error.status ? ` (HTTP ${error.status})` : ''}; private log retained.\n`);
    process.exitCode = 2;
  } finally {
    if (context.containerId) runFile('docker', ['rm', '--force', context.containerId]);
    context.apiKey = '';
  }
}

function selfTest() {
  assert.equal(parseArgs(['--self-test']).self_test, true);
  assert.equal(isCredentialShapedPath('.env.example'), false);
  assert.equal(isCredentialShapedPath('.env'), true);
  assert.equal(isCredentialShapedPath('docs/secrets/api-key.md'), true);
  assert.equal(parseDotEnv('GEMINI_MODEL=gemini-3.8-flash\nGH_MODELS_TOKEN=ignored').GEMINI_MODEL, MODEL);
  assert.deepEqual(toolDeclarations.map((tool) => tool.name), ['list_dir', 'read_file', 'search_text', 'write_file', 'edit_file', 'run_command']);
  assert.equal(allowedCommand(['npm', 'test']), true);
  assert.equal(allowedCommand(['bash', '-lc', 'cat .env']), false);
  assert.equal(allowedCommand(['npm', 'test', '&&', 'env']), false);
  assert.equal(tail('abcdefgh', 4).endsWith('efgh'), true);
  const base = fs.mkdtempSync(path.join(os.tmpdir(), 'fragment-gemini-selftest-'));
  const outside = fs.mkdtempSync(path.join(os.tmpdir(), 'fragment-gemini-selftest-out-'));
  try {
    fs.writeFileSync(path.join(base, 'file.md'), 'ok');
    fs.writeFileSync(path.join(outside, 'private.md'), 'not visible');
    fs.symlinkSync(path.join(outside, 'private.md'), path.join(base, 'escape.md'));
    assert.equal(fs.readFileSync(validatePath(base, 'file.md'), 'utf8'), 'ok');
    assert.equal(validatePath(base, '.'), fs.realpathSync(base));
    const editableContext = { repoRoot: base, editablePaths: new Set(['file.md']) };
    assert.equal(assertEditable(editableContext, 'file.md'), 'file.md');
    assert.throws(() => assertEditable(editableContext, 'other.md'));
    assert.throws(() => validatePath(base, '../escape'));
    assert.throws(() => validatePath(base, '.env'));
    assert.throws(() => validatePath(base, 'escape.md'));
  } finally {
    fs.rmSync(base, { recursive: true, force: true });
    fs.rmSync(outside, { recursive: true, force: true });
  }
  process.stdout.write('GREEN — Gemini harness self-checks passed\n');
}

const args = parseArgs(process.argv.slice(2));
if (args.self_test) selfTest();
else if (args.positional[0] === 'run') await runBenchmark(args);
else {
  process.stderr.write('Usage: node bench/gemini-runner.mjs --self-test | run --repo PATH --deps PATH --private-dir PATH --system FILE --onboarding FILE --questions FILE --task FILE --run-id ID [--budget N] [--edit-path PATH ...]\n');
  process.exitCode = 2;
}
