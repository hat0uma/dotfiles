import $ from "https://deno.land/x/dax@0.35.0/mod.ts";

type NotifyOptions = {
  appName?: string;
  replaceId?: number;
  icon?: string;
  timeout?: number;
  category?: string;
  hint?: string;
  urgency?: "low" | "normal" | "critical";
  actions: { name: string; text: string }[]; // name is used as action id. "default" is reserved for default action.
  wait?: boolean;
  transient?: boolean;
};

class NotifyBuilder<T extends string = ""> {
  private title: string;
  private message: string;
  private opts: NotifyOptions = { actions: [] };

  constructor(title: string, message: string) {
    this.title = title;
    this.message = message;
  }

  setAppName(appName: string) {
    this.opts.appName = appName;
    return this;
  }

  setReplaceId(replaceId: number) {
    this.opts.replaceId = replaceId;
    return this;
  }

  setIcon(icon: string) {
    this.opts.icon = icon;
    return this;
  }

  setTimeout(timeout: number) {
    this.opts.timeout = timeout;
    return this;
  }

  setCategory(category: string) {
    this.opts.category = category;
    return this;
  }

  setHint(hint: string) {
    this.opts.hint = hint;
    return this;
  }

  setUrgency(urgency: "low" | "normal" | "critical") {
    this.opts.urgency = urgency;
    return this;
  }

  addAction<N extends string>(name: N, text: string): NotifyBuilder<T | N> {
    this.opts.actions.push({ name: name, text: text });
    return this;
  }

  setWait(wait = true) {
    this.opts.wait = wait;
    return this;
  }

  setTransient(transient = true) {
    this.opts.transient = transient;
    return this;
  }

  async send(): Promise<T | ""> {
    const args = [this.title, this.message];
    if (this.opts.appName) args.push(`--app-name=${this.opts.appName}`);
    if (this.opts.replaceId) args.push(`--replace-id=${this.opts.replaceId}`);
    if (this.opts.icon) args.push(`--icon=${this.opts.icon}`);
    if (this.opts.timeout) args.push(`--expire-time=${this.opts.timeout}`);
    if (this.opts.category) args.push(`--category=${this.opts.category}`);
    if (this.opts.hint) args.push(`--hint=${this.opts.hint}`);
    if (this.opts.urgency) args.push(`--urgency=${this.opts.urgency}`);
    if (this.opts.wait) args.push(`--wait`);
    if (this.opts.transient) args.push(`--transient`);
    for (const a of this.opts.actions) {
      args.push(`--action=${a.name}=${a.text}`);
    }

    if ((this.opts.wait || this.opts.actions) && this.opts.timeout) {
      // if `wait` or `actions` is specified, timeout is ignored.
      const text = await $`notify-send ${args}`.timeout(this.opts.timeout).noThrow().text();
      return this.parseResult(text);
    } else {
      const text = await $`notify-send ${args}`.text();
      return this.parseResult(text);
    }
  }

  private parseResult(result: string): T | "" {
    if (result === "") {
      return "";
    }
    if (this.opts.actions.some((e) => e.name === result)) {
      return result as T;
    }
    throw new Error(`Unknown result: ${result}`);
  }
}

export function notify(title: string, message: string) {
  return new NotifyBuilder(title, message);
}
