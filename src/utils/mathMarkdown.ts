import rehypeKatex from 'rehype-katex';

const DEVANAGARI_IN_MATH_REGEX = /[\u0900-\u097F]/;
const DEVANAGARI_TEXT_RUN_REGEX = /([\u0900-\u097F]+(?:\s+[\u0900-\u097F]+)*)/g;
const LATEX_TEXT_COMMAND_REGEX = /\\(?:text|textrm|textbf|textit|operatorname)\s*\{/;

const repairJsonEscapedLatexLoss = (content: string) =>
  content
    // JSON-parsed \t and \r sequences can eat the backslash from commands like \text, \to, \rightarrow.
    .replace(/\t(?=[A-Za-z])/g, '\\t')
    .replace(/\r(?=[A-Za-z])/g, '\\r');

const normalizeMathContent = (content: string) => {
  const repairedContent = repairJsonEscapedLatexLoss(content);

  if (!DEVANAGARI_IN_MATH_REGEX.test(repairedContent)) {
    return repairedContent;
  }

  if (LATEX_TEXT_COMMAND_REGEX.test(repairedContent)) {
    return repairedContent;
  }

  return repairedContent.replace(DEVANAGARI_TEXT_RUN_REGEX, (_, match: string) => `\\text{${match.trim()}}`);
};

export const sanitizeMathMarkdown = (input: string) => {
  if (!input || !input.includes('$')) {
    return input;
  }

  let output = '';
  let index = 0;

  while (index < input.length) {
    const currentChar = input[index];

    if (currentChar !== '$' || (index > 0 && input[index - 1] === '\\')) {
      output += currentChar;
      index += 1;
      continue;
    }

    const delimiter = input[index + 1] === '$' ? '$$' : '$';
    const contentStart = index + delimiter.length;
    const contentEnd = input.indexOf(delimiter, contentStart);

    if (contentEnd === -1) {
      output += currentChar;
      index += 1;
      continue;
    }

    const content = input.slice(contentStart, contentEnd);
    output += `${delimiter}${normalizeMathContent(content)}${delimiter}`;
    index = contentEnd + delimiter.length;
  }

  return output;
};

export const createKatexRehypePlugin = () => [
  rehypeKatex as any,
  { strict: 'ignore' as const, throwOnError: false }
] as any;

export const katexRehypePlugin = createKatexRehypePlugin();
