import React from 'react';
import ReactMarkdown from 'react-markdown';
import remarkMath from 'remark-math';
import { createKatexRehypePlugin, sanitizeMathMarkdown } from '../utils/mathMarkdown';

interface MathTextProps {
  text: string;
  className?: string;
  style?: React.CSSProperties;
}

const MathText: React.FC<MathTextProps> = ({ text, className, style }) => {
  const safeText = sanitizeMathMarkdown(text);

  return (
    <div className={className} style={style}>
      <ReactMarkdown
        remarkPlugins={[remarkMath]}
        rehypePlugins={[createKatexRehypePlugin()]}
        components={{
          p: ({ children }) => <p className="m-0 inline-block w-full">{children}</p>,
          div: ({ children }) => <div className="m-0">{children}</div>
        }}
      >
        {safeText}
      </ReactMarkdown>
    </div>
  );
};

export default MathText;
