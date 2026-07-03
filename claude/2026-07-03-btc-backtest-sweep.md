# BTC setup sweep — 3 hypothesis families tested and killed (2026-07-03)

For Codex: joint backtest session (you ran the Python replication via codex exec; your sandbox had no Python/network so Claude executed your codex_backtest.py — results in Desktop\CLAUDE\codex_backtest_results.md).

## Results (BTCUSDT, pre-registered rules, costs included)
| Setup | TV Strategy Tester | Codex/ccxt (2017-2026) | Verdict |
|---|---|---|---|
| Box breakout long 4H | PF 0.73, n=50 | not run | KILLED |
| Failed-box fade short 4H | PF 0.47, n=76 | PF 0.69 full / 0.44 OOS, n=64 | KILLED (both engines) |
| Trend pullback long 4H | PF 0.985, n=113 | PF 0.980, n=485; IS 1.12 -> OOS 0.77 | KILLED — flat-zero and decaying |

## Working conclusions
1. Simple single-pattern mechanical rules on BTC 4H do not clear retail costs (0.1%+slip). Gross trend edge exists but costs absorb it exactly.
2. Next candidates should reduce trade count / raise signal quality (higher TF structure + confluence) or cut costs (limit entries, maker fees).
3. Will's Gate Q pipeline is working: 3 families killed for . Multiple-comparisons tally now at 3 — the qualification bar rises.

## Env notes for future sessions
- Python 3.12 now installed user-scope: %LOCALAPPDATA%\Programs\Python\Python312\python.exe (ccxt, pandas installed)
- TradingView Desktop is MS Store build; relaunch with --remote-debugging-port=9222 after every app update (path version changes)
- Trade log: Desktop\CLAUDE\trade_log.md

## UPDATE (later same day): first QUALIFIED setups found
- SPY + BHP.AX daily momentum-pullback (3R) passed full Gate Q incl OOS + Monte Carlo + plateau. ETH candidate demoted to watch (MC fail). SOL fail. Machine: edge_search.py (crypto) / edge_search_eq.py (equities) in Desktop\CLAUDE.

## UPDATE 3: mean-reversion class qualified (SPY/QQQ/BHP), portfolio at 5 setups, ~31 tr/yr, P(profit yr)=81%. Normal-pain bands measured and wired into both trade skills.

## UPDATE 4: adversarial audit found 20+ flaws; fixes re-ran everything. BHP-MR disqualified (cost mirage). 4 setups survive deflated (SPY mr strongest: OOS PF 1.95, GFC-era 2.93). Pain bands corrected via block bootstrap (P down-year 27%). Execution safety + decay tripwires written into both skills.
