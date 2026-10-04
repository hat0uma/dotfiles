import Pango from "gi://Pango";

// Notification bodies may contain the "body-markup" subset of the spec
// (<b> <i> <u> <a href> <img>), but often also plain text with stray `<` or `&`.
// Convert to safe Pango markup: keep b/i/u, turn links into underlined text,
// drop images and escape everything else.

const ENTITY = /^&(amp|lt|gt|quot|apos|#\d+|#x[0-9a-f]+);/i;

function escapeText(text: string) {
  let out = "";
  for (let i = 0; i < text.length; i++) {
    const char = text[i];
    if (char === "&") out += ENTITY.test(text.slice(i)) ? "&" : "&amp;";
    else if (char === "<") out += "&lt;";
    else if (char === ">") out += "&gt;";
    else out += char;
  }
  return out;
}

const TAG = /<(\/?)([a-z]+)\b[^>]*?(\/?)>/gi;

export function toPangoMarkup(text: string) {
  let out = "";
  let last = 0;
  const open: string[] = [];
  for (const match of text.matchAll(TAG)) {
    out += escapeText(text.slice(last, match.index));
    last = match.index! + match[0].length;
    const [, closing, rawName] = match;
    const name = rawName.toLowerCase();
    if (name === "br") {
      out += "\n";
    } else if (["b", "i", "u", "a"].includes(name)) {
      const tag = name === "a" ? "u" : name;
      if (!closing) {
        open.push(tag);
        out += `<${tag}>`;
      } else if (open[open.length - 1] === tag) {
        open.pop();
        out += `</${tag}>`;
      }
    } else if (name !== "img") {
      out += escapeText(match[0]);
    }
  }
  out += escapeText(text.slice(last));
  while (open.length) out += `</${open.pop()}>`;

  try {
    Pango.parse_markup(out, -1, "\0");
    return out;
  } catch {
    return escapeText(text.replace(TAG, ""));
  }
}
