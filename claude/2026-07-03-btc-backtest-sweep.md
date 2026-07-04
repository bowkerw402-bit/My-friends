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

## UPDATE 5: 5 more replay paper reps done (4 verified, 1 partial). Paper ~85% of sim R on identical trades. Found real BHP data misalignment (yfinance vs ASX) -> caveat in skill: confirm BHP signals on live chart. SPY/QQQ feeds verified clean.

## UPDATE 6 (Jul 4): class #3 (NR7 breakout) qualified on QQQ/BHP/GLD; GLD passed both existing classes (MR OOS PF 3.85!). Book now 9 setups, ~60 tr/yr: P(profitable year) 85.7%, median +18.5%/yr. Pain bands updated (streaks to 15 are in-plan).

## UPDATE 7 (Jul 4): round-3 validation — 10-run perturbation battery + Codex 7-finding code review. 2 HIGH bugs fixed (gap stops, notional cap). Corrected headline: P(profit yr) 77.6%, median +14%/yr. Book intact (9/9 PF>1). Open item: MR grid honest-exit re-selection.

## UPDATE 8 (Jul 4): growth council + tests. Runner exits qualified on trend classes (5/6 improved, avg R +35%). Regime sizing rejected by data. Council consensus: capital + going live > further optimization at this size.

## UPDATE 9 (Jul 4): round-4 — MR provenance closed, runners integrated, GLD-MR upgraded, TLT rejected. Headline: P(profit yr) 80.9%, median +16.6%/yr, 3yr median +60%.

## UPDATE 10 (Jul 4): round-5 — shorts rejected (0/32), MR travels to SLV/IWM/XLE, EEM-vcb added. 13-setup book: P(profit yr) 83.3%, median +19.5%/yr, 3yr median +74%.

## UPDATE 11 (Jul 4): NULL TESTS — honesty reckoning. Only SPY-mr & IWM-mr beat random-in-uptrend. Other 11 setups = bull-market beta + risk mgmt, not signal alpha. 83%/+19% is a BULL-REGIME number. System re-labeled honestly: disciplined harvester w/ ~2 real edges. Not 13 alpha edges. Correlation: effective 8 of 13.
