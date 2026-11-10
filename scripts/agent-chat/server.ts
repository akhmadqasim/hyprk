// Tiny relay so the Claude session on the PC and the one on the Mac can talk.
//   bun scripts/agent-chat/server.ts            (HOST, PORT, HYPRK_CHAT_TOKEN_FILE, HYPRK_CHAT_LOG from env)
// Listen (Claude Monitor tool, ws source):  ws://HOST:PORT/ws?token=T&name=<pc|mac>&since=<last id seen>
//   every message from the OTHER side arrives as one text frame "#<id> [<from>] <text>"; messages with
//   id > since are replayed on connect, so nothing is lost while a monitor was not armed.
// Send:     curl -sS --data-binary @- "http://HOST:PORT/send?token=T&from=<pc|mac>"   (text on stdin)
// History:  curl -sS "http://HOST:PORT/log?token=T&since=0"
// The token is a shared secret kept outside the repo. Nothing here is encrypted: LAN only, no secrets in messages.
import type { ServerWebSocket } from "bun";
import { appendFileSync, existsSync, mkdirSync, readFileSync } from "node:fs";
import { dirname } from "node:path";

const home = process.env.HOME ?? "";
const tokenFile = process.env.HYPRK_CHAT_TOKEN_FILE ?? `${home}/.config/hyprk-chat/token`;
const logFile = process.env.HYPRK_CHAT_LOG ?? `${home}/.local/state/hyprk-chat/log.jsonl`;
const token = readFileSync(tokenFile, "utf8").trim();
if (token.length < 16) throw new Error("token too short");
const inbox = process.env.HYPRK_CHAT_INBOX ?? `${dirname(logFile)}/inbox`;
mkdirSync(inbox, { recursive: true });

type Msg = { id: number; from: string; ts: string; text: string };
type Peer = { name: string; since: number };
const msgs: Msg[] = existsSync(logFile)
    ? readFileSync(logFile, "utf8").split("\n").filter(Boolean).map((l) => JSON.parse(l))
    : [];
const peers = new Set<ServerWebSocket<Peer>>();
const MAX = 8000; // characters per message; bigger things go through git
const line = (m: Msg) => `#${m.id} [${m.from}] ${m.text}`;
const name = (s: string | null) => (s && /^[a-z0-9-]{1,16}$/.test(s) ? s : null);

const server = Bun.serve<Peer, never>({
    hostname: process.env.HOST ?? "0.0.0.0",
    port: Number(process.env.PORT ?? 8787),
    maxRequestBodySize: 512 * 1024 * 1024, // for /put
    async fetch(req, srv) {
        const url = new URL(req.url);
        if (url.searchParams.get("token") !== token) return new Response("forbidden\n", { status: 403 });
        const since = Number(url.searchParams.get("since") ?? 0) || 0;
        if (url.pathname === "/ws") {
            const who = name(url.searchParams.get("name"));
            if (!who) return new Response("name?\n", { status: 400 });
            return srv.upgrade(req, { data: { name: who, since } }) ? undefined : new Response("upgrade failed\n", { status: 400 });
        }
        if (url.pathname === "/send" && req.method === "POST") {
            const from = name(url.searchParams.get("from"));
            const text = (await req.text()).trim();
            if (!from || !text) return new Response("from and a body are required\n", { status: 400 });
            if (text.length > MAX) return new Response(`too long (${text.length} > ${MAX}), put it in git and send the path\n`, { status: 413 });
            const m: Msg = { id: (msgs.at(-1)?.id ?? 0) + 1, from, ts: new Date().toISOString(), text };
            msgs.push(m);
            appendFileSync(logFile, JSON.stringify(m) + "\n");
            let heard = 0;
            for (const ws of peers) if (ws.data.name !== from) { ws.send(line(m)); heard++; }
            return new Response(`ok #${m.id}, ${heard} listening\n`);
        }
        if (url.pathname === "/put" && req.method === "PUT") {
            // curl -sS -T file "http://HOST:PORT/put?token=T&name=<file name>": files too big for git land in the inbox
            const base = (url.searchParams.get("name") ?? "").replace(/[^A-Za-z0-9._ -]/g, "_").replace(/^\.+/, "");
            if (!base) return new Response("name?\n", { status: 400 });
            const dest = `${inbox}/${base}`;
            const bytes = await Bun.write(dest, req);
            return new Response(`ok ${bytes} bytes -> ${dest}\n`);
        }
        if (url.pathname === "/log") return new Response(msgs.filter((m) => m.id > since).map(line).join("\n") + "\n");
        return new Response("not found\n", { status: 404 });
    },
    websocket: {
        open(ws) {
            peers.add(ws);
            for (const m of msgs) if (m.id > ws.data.since && m.from !== ws.data.name) ws.send(line(m));
        },
        close(ws) { peers.delete(ws); },
        message() {}, // sending goes through POST /send so every message gets an id
    },
});
console.log(`agent-chat on ${server.hostname}:${server.port}, ${msgs.length} messages in ${logFile}`);
