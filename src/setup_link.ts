#!/usr/bin/env -S deno run -A --unstable

import * as path from "https://deno.land/std@0.209.0/path/mod.ts";
import { expandGlob } from "https://deno.land/std@0.210.0/fs/expand_glob.ts";
import { exists } from "https://deno.land/std@0.201.0/fs/exists.ts";

const __dirname = path.dirname(path.fromFileUrl(import.meta.url));
const IGNORE_SCRIPTS = [
  "setup.ts",
  "setup_link.ts",
  "setup_nvidia.ts",
];

export async function linkScripts() {
  const dest = Deno.env.get("HOME") + "/.local/bin";
  const wrapperScript = `${__dirname}/dotsdeno.sh`;
  for await (const script of expandGlob(`${__dirname}/*.ts`)) {
    if (!script.isFile || IGNORE_SCRIPTS.includes(script.name)) {
      continue;
    }

    // create symlink wrapper script, because relative import is not working with symlink
    const newPath = `${dest}/${script.name.replace(".ts", "")}`;
    if (await exists(newPath)) {
      const stat = await Deno.lstat(newPath);
      if (stat.isSymlink) {
        console.log(`remove symlink ${newPath}`);
        await Deno.remove(newPath);
      } else {
        console.error(`${newPath} is already exists. skip`);
        continue;
      }
    }
    console.log(`create symlink ${newPath}`);
    await Deno.symlink(wrapperScript, newPath, { type: "file" });
  }
}

if (import.meta.main) {
  await linkScripts();
}
