# handoffs/

Where Claude and Codex hand work to each other — visibly. When one agent needs something only the other
can do (an account, a capability, a second opinion), it writes a handoff here instead of pretending it can
do it. You can see every handoff, who owns it, and its reply.

- One file per handoff: `<date>-<from>-to-<to>-<slug>.md` (template: `_templates/handoff.md`).
- `status:` open → in-progress → done. The receiver writes their reply at the bottom.
- Who-can-do-what lives in `_reference/capabilities.md`.
- Quick way to write one: the `handoff` verb — `handoff codex "the ask" <venture>`.
