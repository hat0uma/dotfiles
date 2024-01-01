#!/usr/bin/env -S deno run -A --unstable

import * as path from "https://deno.land/std@0.209.0/path/mod.ts";
import { expandGlob } from "https://deno.land/std@0.210.0/fs/expand_glob.ts";

const __dirname = path.dirname(path.fromFileUrl(import.meta.url));

async function main() {
  const dest = Deno.env.get("HOME") + "/.local/bin";
  for await (const script of expandGlob(`${__dirname}/*.ts`)) {
    if (!script.isFile || script.name === "setup.ts") {
      continue;
    }

    // use script instead of symlink. because symlink can't resolve import path.
    const destPath = `${dest}/${script.name.replace(".ts", "")}`;
    await Deno.writeTextFile(destPath, `${script.path} "$@"`, { create: true, append: false });
    await Deno.chmod(destPath, 0o755);
  }
}

main();
