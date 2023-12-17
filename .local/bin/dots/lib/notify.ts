import $ from "https://deno.land/x/dax@0.35.0/mod.ts";

type NotifyOptions = {
  appName?: string;
  replaceId?: number;
  icon?: string;
  timeout?: number;
  category?: string;
  hint?: string;
  urgency?: "low" | "normal" | "critical";
  actions?: { name: string; text: string }[]; // name is used as action id. "default" is reserved for default action.
  wait?: boolean;
  transient?: boolean;
};

export function notifySend(title: string, message: string, opts?: NotifyOptions): Promise<string> {
  const args = [];
  if (opts?.appName) args.push(`--app-name=${opts.appName}`);
  if (opts?.replaceId) args.push(`--replace-id=${opts.replaceId}`);
  if (opts?.icon) args.push(`--icon=${opts.icon}`);
  if (opts?.timeout) args.push(`--expire-time=${opts.timeout}`);
  if (opts?.category) args.push(`--category=${opts.category}`);
  if (opts?.hint) args.push(`--hint=${opts.hint}`);
  if (opts?.urgency) args.push(`--urgency=${opts.urgency}`);
  if (opts?.wait) args.push(`--wait`);
  if (opts?.transient) args.push(`--transient`);
  if (opts?.actions) {
    for (const a of opts.actions) {
      args.push(`--action=${a.name}=${a.text}`);
    }
  }
  args.push(title, message);

  if ((opts?.wait || opts?.actions) && opts.timeout) {
    // if `wait` or `actions` is specified, timeout is ignored.
    return $`notify-send ${args}`.timeout(opts.timeout).noThrow().text();
  } else {
    return $`notify-send ${args}`.text();
  }
}
