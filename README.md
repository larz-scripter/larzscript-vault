# LarzVault

A terminal idle/incremental economy game, written entirely in
[Larzscript](https://github.com/larz-scripter/larzscript) - the
money-native programming language. `larzvault.lz` is one file, built on
the `json`, `fs`, `crypto`, `uuid`, and `table` packages from
[larzscript-packages](https://github.com/larz-scripter/larzscript-packages).

## The pitch

Every browser idle game (Cookie Clicker and its hundreds of clones) is
trivially cheatable: open devtools, set a JS variable, done. In
LarzVault, no code path inside the game - not a bug, not a dev command,
not the save-loading path - can ever create currency out of thin air or
skip a spending guardrail, because `wallet`/`pay`/`require` are real
language primitives here, not application logic. You cannot write
`player.balance = 999999` any more than you can assign into a `wallet`
except through a real `pay`. Passive income isn't printed from nothing
either - it's a real `pay` from a large, fixed "World Reserve" wallet
declared once at genesis, so even idle income goes through the exact
same enforcement as every purchase.

**What this claim does *not* cover, stated plainly:** a player can still
hand-edit the raw save file on disk, the same as any local single-player
game. So the save is made **tamper-evident**: it's HMAC-SHA256 signed
with a per-install secret generated on first run (`~/.larzvault/secret`,
`chmod 600`). Casual or accidental tampering - editing a number, copying
someone else's save, a truncated write - is caught and the game refuses
to load it. This is *not* proof against a player determined enough to go
read their own secret file and re-sign a forged save; that's always
possible for local, single-player state with no server to check against.
The honest claim is "casual tampering is caught," not "impossible to
cheat, period."

## Play it

```
larzscript larzvault.lz status
```

```
LarzVault
---------
Balance:   $5.00
Income:    $0.02/s

| Upgrade         | Cost       | +Rate    | Owned |
|-----------------|------------|----------|-------|
| Solar Panel     | $10.00     | +$0.05/s |       |
| Wind Turbine    | $50.00     | +$0.2/s  |       |
| Hydro Plant     | $200.00    | +$0.8/s  |       |
| Geothermal Rig  | $750.00    | +$3/s    |       |
| Fusion Core     | $3000.00   | +$12/s   |       |
| Orbital Array   | $12000.00  | +$50/s   |       |
| Dyson Shard     | $50000.00  | +$220/s  |       |
| Singularity Tap | $250000.00 | +$1000/s |       |

larzscript larzvault.lz buy <id>   (id = one of: solar, wind, hydro, geo, fusion, orbital, dyson, singularity)
```

Buy an upgrade - a real `require()`-guarded `pay()`, refused if you can't
afford it:

```
$ larzscript larzvault.lz buy solar
Not enough for Solar Panel - need $10.00, have $5.04.
```

Come back later (real elapsed time, capped at 8 hours per visit) and
`status` grants what accrued while you were away. This transcript
continues the same save - the 300-second gap is real (simulated by
advancing the save's own `last_seen` field and re-signing it with the
real per-install secret, the identical code path real elapsed time
takes; nothing here is a tamper, since it's signed correctly):

```
$ larzscript larzvault.lz status
LarzVault
---------
While away (301s): earned $6.02

Balance:   $11.06
Income:    $0.02/s
```
```
$ larzscript larzvault.lz buy solar
Bought Solar Panel. New balance: $1.10. Income: $0.07/s
```

`larzscript larzvault.lz reset` deletes the save and starts over.

## The tamper-evident save, demonstrated for real

Continuing the same save - now a real hand-edit, *without* knowing the
secret, so the signature no longer matches:

```
$ sed -i 's/\\"player_cents\\":[0-9]*/\\"player_cents\\":999999999/' ~/.larzvault/save.json
$ larzscript larzvault.lz status
This save's signature doesn't match its contents - been in the file, have you?
Refusing to load a tampered/corrupted save. (/home/you/.larzvault/save.json)
```

The save file is `{"payload": "<the exact JSON string that was signed>",
"sig": "<HMAC-SHA256 of payload>"}`. Verification re-computes the HMAC
over the *exact* stored payload string (never a re-serialized copy, so
there's no dict-ordering edge case in the comparison) and refuses to
load on any mismatch.

## How the economy is actually enforced

- `wallet`/`price`/`pay ... from ... to ...`/`require ..., "msg"` are
  real Larzscript language statements (see
  [`native/LANGUAGE.md`](https://github.com/larz-scripter/larzscript/blob/main/native/LANGUAGE.md#9-money-the-money-native-core)
  section 9) - `pay` throws a `MoneyError` if the source can't cover the
  amount, `require` throws a catchable `RequireError` if its condition
  is false. Both are caught by the CLI layer and turned into a clean
  message; neither can be silently bypassed by other code.
- A "World Reserve" wallet, `$999,999,999.00`, is declared once at
  genesis. Every unit of passive/idle income is a real `pay` from that
  reserve to the player - large but *finite*, so even "free" money has a
  real, enforced source, not a bypass of the money system.
- Money is exact integer cents (the native type); the passive income
  *rate* (`$/s`) is a plain float, since a rate isn't itself a balance -
  income is only actually paid in whole-cent chunks
  (`floor(rate * elapsed_seconds * 100)`), so sub-cent accrual is simply
  not yet granted, never invented or rounded up.

## Limitations (stated honestly)

- **Save tampering**: see above - casual tampering is caught, a
  determined local attacker who reads their own secret file is not
  stopped. There is no server, so there's nothing to check a save
  against beyond internal consistency.
- **Offline cap**: idle progress caps at 8 hours per `status` call (a
  deliberate idle-game design choice against unbounded catch-up, not a
  technical limit) - `OFFLINE_CAP_SECONDS` in `larzvault.lz`.
- **Single-player, local-only**: no multiplayer, no leaderboard, no
  network calls at all.
- **Upgrades are one-time**: each of the 8 upgrades can be bought once;
  this is a small, honest flagship demo, not a deep incremental game.

## Tests

```
sh tests/run_tests.sh
```

Covers: a fresh game's starting state, a purchase correctly refused for
insufficient funds, a purchase that correctly succeeds and raises the
income rate, buying the same upgrade twice correctly rejected the second
time, and the tamper-evident save correctly refusing a corrupted
signature. All real captured output, nothing fabricated.

## License

MIT
