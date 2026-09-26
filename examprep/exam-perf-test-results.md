- [Go Top](../index.html)
- [Go Index](./index.html)
- [Go Back](./project.html)
- [Go Next](./project.html)


# 250-Run Parallel AI Workflow Report

Generated 2026-09-21T11:15:33.131534+00:00. Each area ran 250 times in fixed parallel batches of five.

| ID | Test area | Good test | Bad test | Average ms | P95 ms | Maximum ms | Overall |
|---|---|---:|---:|---:|---:|---:|---|
| T1 | Speech test | 100.0% (optimal) | 100.0% (optimal) | 0.002 (optimal) | 0.003 (optimal) | 0.012 (optimal) | optimal |
| T2 | Word | 100.0% (optimal) | 100.0% (optimal) | 0.001 (optimal) | 0.002 (optimal) | 0.005 (optimal) | optimal |
| T3 | Text generation | 100.0% (optimal) | 100.0% (optimal) | 0.001 (optimal) | 0.001 (optimal) | 0.003 (optimal) | optimal |
| T4 | Exam with interactive feedback | 100.0% (optimal) | 100.0% (optimal) | 0.001 (optimal) | 0.001 (optimal) | 0.002 (optimal) | optimal |
| T5 | Real exam submission and return | 100.0% (optimal) | 100.0% (optimal) | 0.000 (optimal) | 0.000 (optimal) | 0.001 (optimal) | optimal |
| T6 | ASR metrics | 100.0% (optimal) | 100.0% (optimal) | 0.000 (optimal) | 0.001 (optimal) | 0.001 (optimal) | optimal |
| T7 | HuBERT metrics | 100.0% (optimal) | 100.0% (optimal) | 0.000 (optimal) | 0.000 (optimal) | 0.001 (optimal) | optimal |
| T8 | BERT Model Training | 100.0% (optimal) | 100.0% (optimal) | 0.000 (optimal) | 0.000 (optimal) | 0.001 (optimal) | optimal |
| T9 | Text generation training | 100.0% (optimal) | 100.0% (optimal) | 0.000 (optimal) | 0.000 (optimal) | 0.001 (optimal) | optimal |
| T10 | Hybrid search question answering | 100.0% (optimal) | 100.0% (optimal) | 0.000 (optimal) | 0.000 (optimal) | 0.001 (optimal) | optimal |
| T11 | ASAG question-answer scoring | 100.0% (optimal) | 100.0% (optimal) | 0.000 (optimal) | 0.000 (optimal) | 0.001 (optimal) | optimal |

Success/rejection: optimal = 100%, good >= 99%. In-process latency: optimal <= 5 ms, good <= 50 ms. Bad tests succeed when they reject invalid input.


# 3.3 AI Workflow Good/Bad Test Report

> **✅ Optimal** — All 11 workflow areas produced the expected positive outcome and correctly rejected the negative condition under 5 × 250 parallel load.

This report records the Chatbot workflow tests together with ASR, HuBERT, BERT training, text-generation training, hybrid search, and ASAG question-answer quality gates. *(H. Glab-Plhak, 2026).*

Report generated: `2026-09-22T21:53:09.141865+00:00`

## How the result is interpreted

- A **✅ Good test** means the expected valid condition was accepted.
- A **✅ Bad test** means the invalid or unsafe condition was correctly rejected or flagged.
- A bad test would receive **❌** only if the invalid condition were unexpectedly accepted.

## At a glance

| Measurement | Result | Assessment |
|---|---:|---|
| Test areas | 11 | Complete |
| Parallel system load | 250 batches × 5 workers | 1250 suites |
| Paired good/bad tests | 13750 | All completed |
| Individual decisions | 27500 | 27500 correct |
| Overall correctness | 100.0% | ✅ Optimal |
| Measured wall time | 52.781 ms | In-process rules |
| Processing rate | 260,509.79 paired tests/s | ✅ Optimal |

## 3.3.1 Result table

### Core application workflows

| ID | Test area | Good test | Bad test | Average latency | P95 latency | Result |
|---|---|---:|---:|---:|---:|---|
| T1 | Speech test | ✅ 1250/1250 (100.0%) | ✅ 1250/1250 (100.0%) | 0.001706 ms | 0.002291 ms | ✅ Optimal |
| T2 | Word | ✅ 1250/1250 (100.0%) | ✅ 1250/1250 (100.0%) | 0.001292 ms | 0.001833 ms | ✅ Optimal |
| T3 | Text generation | ✅ 1250/1250 (100.0%) | ✅ 1250/1250 (100.0%) | 0.000983 ms | 0.001333 ms | ✅ Optimal |
| T4 | Exam with interactive feedback | ✅ 1250/1250 (100.0%) | ✅ 1250/1250 (100.0%) | 0.000671 ms | 0.000875 ms | ✅ Optimal |
| T5 | Real exam submission and return | ✅ 1250/1250 (100.0%) | ✅ 1250/1250 (100.0%) | 0.000321 ms | 0.000417 ms | ✅ Optimal |

### AI quality, training, search, and scoring gates

| ID | Test area | Good test | Bad test | Average latency | P95 latency | Result |
|---|---|---:|---:|---:|---:|---|
| T6 | ASR metrics | ✅ 1250/1250 (100.0%) | ✅ 1250/1250 (100.0%) | 0.000339 ms | 0.000459 ms | ✅ Optimal |
| T7 | HuBERT metrics | ✅ 1250/1250 (100.0%) | ✅ 1250/1250 (100.0%) | 0.000280 ms | 0.000375 ms | ✅ Optimal |
| T8 | BERT Model Training | ✅ 1250/1250 (100.0%) | ✅ 1250/1250 (100.0%) | 0.000260 ms | 0.000334 ms | ✅ Optimal |
| T9 | Text generation training | ✅ 1250/1250 (100.0%) | ✅ 1250/1250 (100.0%) | 0.000284 ms | 0.000375 ms | ✅ Optimal |
| T10 | Hybrid search question answering | ✅ 1250/1250 (100.0%) | ✅ 1250/1250 (100.0%) | 0.000296 ms | 0.000416 ms | ✅ Optimal |
| T11 | ASAG question-answer scoring | ✅ 1250/1250 (100.0%) | ✅ 1250/1250 (100.0%) | 0.000295 ms | 0.000375 ms | ✅ Optimal |

## 3.3.2 Test descriptions

### T1 — Speech test

- **Purpose:** Spoken input is recognized as a Chatbot command when it contains @chatbot and a research or scoring intent.
- **Acceptance metrics:** Command recognized, intent present, and a negative sentence without @chatbot is rejected.
- **Good test:** 1250/1250 accepted — ✅ Optimal.
- **Bad test:** 1250/1250 correctly rejected — ✅ Optimal.
- **Latency:** average 0.001706 ms; median 0.001500 ms; P95 0.002291 ms; maximum 0.055958 ms.

### T2 — Word

- **Purpose:** A Word document is accepted as usable Chatbot input when it is a DOCX file containing an exam question.
- **Acceptance metrics:** DOCX recognized, text length sufficient, and question marker present.
- **Good test:** 1250/1250 accepted — ✅ Optimal.
- **Bad test:** 1250/1250 correctly rejected — ✅ Optimal.
- **Latency:** average 0.001292 ms; median 0.001042 ms; P95 0.001833 ms; maximum 0.077417 ms.

### T3 — Text generation

- **Purpose:** Text generation is allowed only for a sufficiently specific exam prompt and a freely available model.
- **Acceptance metrics:** Free model, sufficient prompt length, and exam context.
- **Good test:** 1250/1250 accepted — ✅ Optimal.
- **Bad test:** 1250/1250 correctly rejected — ✅ Optimal.
- **Latency:** average 0.000983 ms; median 0.000875 ms; P95 0.001333 ms; maximum 0.017917 ms.

### T4 — Exam with interactive feedback

- **Purpose:** Interactive feedback is allowed only for a practice exam, not for a real examination mode.
- **Acceptance metrics:** Feedback only for practice=true; real examination feedback is blocked.
- **Good test:** 1250/1250 accepted — ✅ Optimal.
- **Bad test:** 1250/1250 correctly rejected — ✅ Optimal.
- **Latency:** average 0.000671 ms; median 0.000542 ms; P95 0.000875 ms; maximum 0.019708 ms.

### T5 — Real exam submission and return

- **Purpose:** A real graded exam is successful only when the student signature, instructor signature, and return state exist.
- **Acceptance metrics:** Real exam, student signature, instructor signature, and return state.
- **Good test:** 1250/1250 accepted — ✅ Optimal.
- **Bad test:** 1250/1250 correctly rejected — ✅ Optimal.
- **Latency:** average 0.000321 ms; median 0.000292 ms; P95 0.000417 ms; maximum 0.007583 ms.

### T6 — ASR metrics

- **Purpose:** ASR is recorded with word error rate, character error rate, latency, and transcript confidence.
- **Acceptance metrics:** WER≤0.10, CER≤0.05, latency≤500 ms, and confidence≥0.85.
- **Good test:** 1250/1250 accepted — ✅ Optimal.
- **Bad test:** 1250/1250 correctly rejected — ✅ Optimal.
- **Latency:** average 0.000339 ms; median 0.000333 ms; P95 0.000459 ms; maximum 0.002291 ms.

### T7 — HuBERT metrics

- **Purpose:** HuBERT is evaluated with audio embedding similarity, intent cluster purity, and latency.
- **Acceptance metrics:** Similarity≥0.85, purity≥0.80, and latency≤500 ms.
- **Good test:** 1250/1250 accepted — ✅ Optimal.
- **Bad test:** 1250/1250 correctly rejected — ✅ Optimal.
- **Latency:** average 0.000280 ms; median 0.000250 ms; P95 0.000375 ms; maximum 0.010459 ms.

### T8 — BERT Model Training

- **Purpose:** BERT training is accepted when loss decreases, evaluation accuracy is sufficient, and shortcut mitigation is active.
- **Acceptance metrics:** Loss 1.20→0.42, accuracy≥0.80, and shortcut penalty active.
- **Good test:** 1250/1250 accepted — ✅ Optimal.
- **Bad test:** 1250/1250 correctly rejected — ✅ Optimal.
- **Latency:** average 0.000260 ms; median 0.000250 ms; P95 0.000334 ms; maximum 0.005375 ms.

### T9 — Text generation training

- **Purpose:** Text-generation training is accepted when loss and perplexity decrease and a freely available model is used.
- **Acceptance metrics:** Loss 2.40→1.10, PPL 18.0→6.2, and free model.
- **Good test:** 1250/1250 accepted — ✅ Optimal.
- **Bad test:** 1250/1250 correctly rejected — ✅ Optimal.
- **Latency:** average 0.000284 ms; median 0.000250 ms; P95 0.000375 ms; maximum 0.002792 ms.

### T10 — Hybrid search question answering

- **Purpose:** Hybrid-search question answering is accepted when relevant sources rank at the top and the answer is well grounded.
- **Acceptance metrics:** Precision@2≥0.90, recall@2≥0.90, MRR≥0.90, NDCG@3≥0.90, and source coverage≥0.90.
- **Good test:** 1250/1250 accepted — ✅ Optimal.
- **Bad test:** 1250/1250 correctly rejected — ✅ Optimal.
- **Latency:** average 0.000296 ms; median 0.000291 ms; P95 0.000416 ms; maximum 0.001375 ms.

### T11 — ASAG question-answer scoring

- **Purpose:** ASAG question-answer scoring is accepted when score, semantics, keywords, facts, and contradiction safety are strong.
- **Acceptance metrics:** Score≥0.75, semantic≥0.80, keywords≥0.75, fact entailment≥0.80, and contradiction safety≥0.80.
- **Good test:** 1250/1250 accepted — ✅ Optimal.
- **Bad test:** 1250/1250 correctly rejected — ✅ Optimal.
- **Latency:** average 0.000295 ms; median 0.000250 ms; P95 0.000375 ms; maximum 0.032833 ms.

## 3.3.3 Quality scale

- **Outcome rate:** optimal at 100%; good at 99% or higher; otherwise suboptimal.
- **Rule latency:** optimal at 5 ms or less; good at 50 ms or less; otherwise suboptimal.

## 3.3.4 Scope

The timings measure deterministic in-process workflow validation and metric gates. They exclude browser speech recognition, actual audio decoding, DOCX parsing, BERT/HuBERT inference, model training, PostgreSQL, hybrid-search storage, network transport, and certificate services. The benchmark therefore demonstrates rule correctness, concurrency stability, and dispatch performance—not end-to-end production latency.
