- [Goto home](../index.html)
- [Goto Top](./project-plan.html)
- [Goto Index](./index.html)


# Unichorn Modernization and Feature Introduction Plan

**Repository:** <https://github.com/hglabplh-tech/unichorn-project>  
**Plan date:** 31 August 2026  
**Target:** A modular, provider-neutral Java platform with independent desktop applications for mail, signature operations, certificate operations, OCSP/revocation and trust management.

## 1. Executive summary

Unichorn should be modernized as a **modular monolith with multiple independently packaged applications**. The first implementation step is to split the current mixed core and GUI into stable domain, API and adapter modules. Only after those boundaries exist should the libraries be upgraded and IAIK be replaced, because IAIK types currently occur across core, GUI, responder and PKCS#11 code.

The principal technology decisions are:

- Use **European Commission Digital Signature Services (DSS)** as the authoritative implementation for PAdES, XAdES, CAdES, ASiC, signature validation, augmentation, EU trusted-list processing, qualification and validation reports.
- Use **Bouncy Castle** for JCA/JCE, CMS/S/MIME, X.509, CSR, PKCS#8/#12, OCSP, CRL and timestamp primitives.
- Retain **PKCS#11 as the standard interface** to signature cards, HSMs and QSCDs, but replace the commercial IAIK PKCS#11 wrapper/provider with the JDK `SunPKCS11` provider, DSS token support and the card vendor's native PKCS#11 driver or OpenSC.
- Make **RFC 5751 compatibility mandatory** for S/MIME. A separate modern-security policy may prefer RFC 8551 algorithms when recipient capabilities permit them.
- Evaluate an optional customer trust list first when it is configured, then evaluate the EU LOTL and national TLv6. Without a customer trust list, use only the EU route.
- Check revocation through OCSP first. If OCSP is unavailable or returns an inconclusive result, use the issuer-signed CRL published through the certificate's CRL Distribution Point.
- Expose every use case through provider-neutral Java interfaces. GUI controllers, CLI commands and responder endpoints call the same interfaces.

## 2. Current-state problems to resolve

The current Maven reactor contains four modules:

- `unichorn-core`
- `unichorn-gui-fx`
- `unichorn-pkcs11`
- `unichorn-responder`

The modernization must address these concrete issues:

1. `unichorn-core` combines signatures, certificates, trust lists, OCSP/CRL, mail, HTTP, password management and general utilities.
2. `unichorn-gui-fx` combines mail, signature, certificate, trust, smart-card and unrelated screens in one JavaFX application.
3. IAIK dependencies and `iaik.*` types are spread through all principal modules.
4. The project mixes incompatible or obsolete library generations, including JavaFX 8 and 15 early access, tinylog 1 and 2, iText 5 and 7, Jersey 1 and 2, Java EE 6/Servlet 2.5 and modern libraries.
5. Java source and target are 14.
6. `unichorn-gui-fx` references `unichorn-isearch`, which is not part of the reactor.
7. PKCS#11, certificate objects and provider-specific types escape into application/UI code.
8. Trusted-list schemas, signed configurations, certificates and keystores require classification and regeneration.
9. Validation results are not yet modeled as a single auditable result covering cryptographic validity, revocation, customer trust and eIDAS qualification independently.

## 3. Target module structure

### 3.1 Foundation and public APIs

| Module | Responsibility | May depend on |
|---|---|---|
| `unichorn-domain` | Immutable domain records, identifiers, policies, status models and errors | JDK only where practical |
| `unichorn-application-api` | Public use-case interfaces and provider-neutral DTOs | `unichorn-domain` |
| `unichorn-application` | Use-case orchestration and transaction/workflow logic | domain and API ports |
| `unichorn-config` | Typed configuration, profiles, migration and validation | domain |
| `unichorn-audit` | Structured audit events and evidence manifests | domain |
| `unichorn-test-support` | Generated certificates, deterministic clocks, fixtures and test adapters | test scope only |

### 3.2 Cryptography, signatures and PKI

| Module | Responsibility |
|---|---|
| `unichorn-crypto-bc` | Bouncy Castle provider bootstrap and low-level cryptographic primitives |
| `unichorn-signature-dss` | DSS adapter for AdES creation, validation, augmentation, qualification and reports |
| `unichorn-signature-create` | Signature creation workflow and signing-key selection |
| `unichorn-signature-validate` | Signature format detection, validation and report generation |
| `unichorn-signature-security` | Malformed-input, algorithm, wrapping, PDF/XML/archive and resource-limit checks |
| `unichorn-signature-maintenance` | B-T, B-LT and B-LTA augmentation and archival timestamp renewal |
| `unichorn-certificate-create` | Key pair, CSR, certificate and private/customer CA operations |
| `unichorn-certificate-validate` | X.509 path, name, usage, policy, time and revocation validation |
| `unichorn-token-api` | Provider-neutral smart-card/HSM/QSCD interfaces |
| `unichorn-token-pkcs11` | SunPKCS11/DSS implementation backed by native vendor middleware or OpenSC |

### 3.3 Mail and trust

| Module | Responsibility |
|---|---|
| `unichorn-mail-core` | Account, folder, message, attachment and address-book model |
| `unichorn-mail-transport` | IMAP/SMTP through Jakarta Mail/Angus Mail |
| `unichorn-mail-smime` | RFC 5751 signing, encryption, verification and decryption through Bouncy Castle |
| `unichorn-revocation` | OCSP-first evaluation, CRL fallback, caching and evidence |
| `unichorn-customer-trust` | Tenant-scoped customer root lists, versions, signing, activation and audit |
| `unichorn-eu-trust` | DSS LOTL/national TLv6 synchronization and eIDAS qualification |
| `unichorn-trust-policy` | Customer-first routing and final trust classification |
| `unichorn-network` | Restricted HTTP/LDAP retrieval, caching, timeouts, limits and SSRF controls |

### 3.4 Applications and delivery adapters

| Module/application | Responsibility |
|---|---|
| `unichorn-ui-common` | Shared JavaFX components, accessibility, localization and report display only |
| `unichorn-app-mail` | Independent mail client GUI |
| `unichorn-app-signature-create` | Independent signature-creation GUI |
| `unichorn-app-signature-validate` | Signature validation and vulnerability-analysis GUI |
| `unichorn-app-signature-maintenance` | Signature augmentation/update GUI |
| `unichorn-app-certificate-create` | Certificate, key pair, CSR, keystore and customer-CA GUI |
| `unichorn-app-certificate-validate` | Certificate-path, policy and revocation-validation GUI |
| `unichorn-app-trust-center` | Customer trust lists, EU LOTL/TLv6, OCSP and CRL GUI |
| `unichorn-app-token-manager` | Optional card/token inspection GUI if token management cannot remain embedded in certificate/signature applications |
| `unichorn-cli` | Scriptable commands over the same application interfaces |
| `unichorn-responder` | Optional TSA/OCSP server adapter; no desktop dependencies |

## 4. Mandatory dependency rules

1. Domain and API modules must not import JavaFX, IAIK, Bouncy Castle, DSS, Jakarta Mail, HTTP-client or PKCS#11 implementation classes.
2. Public method signatures use Unichorn DTOs and interfaces, not provider-specific objects.
3. Applications depend inward on interfaces; adapters implement those interfaces.
4. DSS is authoritative for AdES and EU qualification. Bouncy Castle must not become a competing eIDAS policy engine.
5. Bouncy Castle is authoritative for S/MIME/CMS and low-level PKI primitives.
6. Token private keys must never be exported. Token adapters expose sign and decrypt/unwrap operations, not private-key bytes.
7. All network access goes through `unichorn-network`; crypto libraries and GUI controllers do not retrieve arbitrary URLs directly.
8. Each GUI is independently launchable and packageable. `unichorn-ui-common` must not become another business-logic module.

## 5. Recommended free/open-source technology stack

Versions below are the verified baseline on the plan date. At implementation time, select the latest compatible **stable** release and rerun the full interoperability/security suite.

| Function | Recommended component | Baseline | License/notes |
|---|---|---:|---|
| Java runtime | OpenJDK | Prefer JDK 21 first; evaluate JDK 25 after DSS/plugin compatibility tests | GPL-2.0 with Classpath Exception for OpenJDK builds |
| AdES/eIDAS | European Commission DSS | 6.4 stable; test 6.5.RC1 only in compatibility CI | LGPL-2.1; DSS 6.4 is the production baseline on 31 August 2026 |
| Crypto/PKI/CMS/S/MIME | Bouncy Castle `bcprov-jdk18on`, `bcpkix-jdk18on`, `bcmail-jdk18on`, `bctls-jdk18on` only if needed | 1.85 | MIT-style Bouncy Castle license |
| Mail/MIME | Jakarta Mail API + Eclipse Angus Mail | Jakarta Mail 2.1.5 / Angus 2.0.5 | EPL-2.0 or GPL-2.0 with Classpath Exception, depending artifact |
| PKCS#11 JCA provider | JDK `SunPKCS11` | Selected JDK | Included in JDK; use supported provider configuration APIs |
| DSS token signing | DSS `Pkcs11SignatureToken` | Same DSS version | Use for DSS signing workflows behind `TokenService` |
| Native card middleware | Vendor PKCS#11 module or OpenSC | Current supported release | OpenSC LGPL-2.1; support depends on card/token model |
| Desktop GUI | OpenJFX | JavaFX 21 with JDK 21, or JavaFX 25 with JDK 23+ after compatibility approval | GPL-2.0 with Classpath Exception |
| HTTP | Apache HttpComponents Client 5 | Current stable compatible version | Apache-2.0 |
| MIME hardening, optional | Apache James Mime4j | Current stable compatible version | Apache-2.0; add only for malformed/hostile MIME analysis |
| Logging | tinylog 2 **or** SLF4J 2 + Logback | One stack only | Do not retain tinylog 1 and 2 together |
| JSON | Jackson or Gson | One selected current stable line | Avoid multiple JSON models without need |
| Tests | JUnit Jupiter, AssertJ, Mockito Core | Current stable compatible versions | Replace JUnit 4, `mockito-all` and old PowerMock bundles |
| SBOM | CycloneDX Maven plugin | Current stable | Generate at every release |

### 5.1 PKCS#11 clarification and replacement specification

PKCS#11 itself is not an IAIK library and should not be removed. It is the standard interface between Java and a token's native middleware. What must be replaced is:

- `iaik-pkcs11-wrapper`
- `iaik-pkcs11provider-*`
- IAIK token/session/object classes in public and application code

The preferred replacement stack is:

1. `unichorn-token-api` defines `TokenService`, `TokenSession`, `TokenIdentity`, `TokenCertificate`, `TokenCapabilities` and domain exceptions.
2. `unichorn-token-pkcs11` uses the JDK `SunPKCS11` provider and `KeyStore.getInstance("PKCS11")` through supported JCA/JCE APIs.
3. DSS signature workflows use `Pkcs11SignatureToken` internally within the DSS adapter.
4. The operating system loads the card manufacturer's native `.dll`, `.so` or `.dylib`; OpenSC is an alternative only for supported cards.
5. S/MIME card-backed decryption uses JCA `Cipher`/key-unwrapping through the configured provider when the card and driver expose the required mechanisms.
6. Do not import internal `sun.security.pkcs11.*` classes. Do not expose DSS token classes outside the adapter.
7. Only consider a further direct PKCS#11 wrapper if an approved requirement cannot be implemented through standard JCA/DSS, such as advanced object administration or mechanism diagnostics. That decision requires its own license, maintenance and security review.

## 6. Public service interfaces to define

The following interfaces form the stable boundary for GUIs, CLI commands and responder endpoints:

```java
public interface MailService {
    MessageId send(SendMailCommand command);
    MailMessage read(ReadMailQuery query);
}

public interface MimeSecurityService {
    SecuredMimeMessage sign(SignMimeCommand command);
    SecuredMimeMessage encrypt(EncryptMimeCommand command);
    SecuredMimeMessage signThenEncrypt(SignEncryptMimeCommand command);
    DecryptedMimeMessage decrypt(DecryptMimeCommand command);
    MailSecurityReport verify(VerifyMimeCommand command);
}

public interface SignatureCreationService {
    SigningPreparation prepare(CreateSignatureCommand command);
    SignedArtifact complete(CompleteSignatureCommand command);
}

public interface SignatureValidationService {
    SignatureValidationReport validate(ValidateSignatureCommand command);
}

public interface SignatureSecurityAnalysisService {
    SecurityAnalysisReport inspect(InspectArtifactCommand command);
}

public interface SignatureMaintenanceService {
    SignedArtifact augment(AugmentSignatureCommand command);
}

public interface CertificateCreationService {
    KeyReference createKey(CreateKeyCommand command);
    CertificationRequest createCsr(CreateCsrCommand command);
    CertificateBundle issue(IssueCertificateCommand command);
}

public interface CertificateValidationService {
    CertificateValidationReport validate(ValidateCertificateCommand command);
}

public interface TokenService extends AutoCloseable {
    List<TokenDescriptor> discover();
    List<TokenIdentity> identities(TokenId tokenId, PinCallback pinCallback);
    SignatureValue sign(TokenSignCommand command, PinCallback pinCallback);
    DecryptedKeyMaterial decryptOrUnwrap(TokenDecryptCommand command, PinCallback pinCallback);
}

public interface RevocationService {
    RevocationReport check(RevocationRequest request);
}

public interface CustomerTrustListService {
    CustomerTrustListVersion publish(PublishCustomerTrustListCommand command);
    Optional<CustomerTrustList> activeList(TenantId tenantId, Instant validationTime);
}

public interface EuTrustService {
    EuTrustReport evaluate(EuTrustRequest request);
}

public interface TrustPolicyService {
    CombinedTrustReport evaluate(TrustEvaluationCommand command);
}
```

These signatures are architectural examples, not a requirement to preserve the exact names. The critical rule is that no IAIK, Bouncy Castle, DSS, JavaFX or native-driver type appears in them.

## 7. Features and utilities to specify before implementation

### 7.1 Cross-cutting utilities

- `CryptoProviderBootstrap`: deterministic provider registration and startup diagnostics.
- `AlgorithmPolicy`: allowed, deprecated and forbidden algorithms, key sizes and dates.
- `SecureClock`: injected validation/signing time for repeatable tests.
- `DocumentSource`/`DocumentSink`: bounded streaming instead of unrestricted byte arrays.
- `MimeCanonicalizer`: RFC 5751-compatible MIME canonicalization and transfer encoding.
- `SafeNetworkClient`: HTTP/LDAP allow rules, proxy support, TLS, redirect limits, timeouts, maximum sizes and SSRF protection.
- `EvidenceStore`: content-addressed OCSP, CRL, TL/LOTL, timestamp and policy snapshots.
- `SecretProvider`: OS keychain/secret-store abstraction; no credentials in properties files.
- `PolicyRegistry`: versioned validation, trust, algorithm and customer policies.
- `ResultRenderer`: machine-readable JSON/XML and human-readable HTML/PDF summaries.
- `AuditTrail`: correlation IDs, actor, operation, policy version, evidence hashes and outcome.
- `CancellationToken`/progress reporting for JavaFX background operations.

### 7.2 Mail features

- IMAP and SMTP account management with modern TLS and hostname verification.
- MIME compose/read, attachments, address book and safe HTML display.
- RFC 5751 detached and opaque signed mail.
- CMS `EnvelopedData` encryption for one or more recipients.
- Signed-then-encrypted messages and correct nested receive processing.
- Software-keystore and card-backed signing/decryption.
- Recipient-certificate discovery, selection, expiry warning and capabilities cache.
- Separate display of cryptographic validity, certificate validity, revocation, customer trust and eIDAS status.
- Attachment limits, MIME depth limits, archive-bomb protection and safe external-link handling.

### 7.3 Certificate creation features

- Key-pair creation in software keystores or supported tokens.
- CSR creation and inspection.
- Self-signed certificates and customer/private-CA certificate issuance.
- Certificate profiles for CA, signing, encryption, TLS and S/MIME usage.
- Serial-number policy, validity policy, subject/SAN editor, extensions and algorithm enforcement.
- Clear warning that customer-issued certificates may be customer-qualified by local policy but are not eIDAS-qualified merely because the chain is valid.

### 7.4 Certificate and signature validation features

- X.509 path construction and validation at a selected time.
- Key usage, extended key usage, name constraints, policies and algorithm constraints.
- OCSP-first revocation and issuer-CRL fallback.
- DSS validation of PAdES, XAdES, CAdES and ASiC with detailed reports.
- Separate `PASSED`, `FAILED` and `INDETERMINATE` outcomes; never reduce all validation to a boolean.
- Structural/security checks for malformed ASN.1, XML wrapping/XXE, PDF incremental updates/DocMDP, ZIP/archive bombs, duplicate identifiers, external references and resource exhaustion.

### 7.5 Customer and EU trust features

- Customer trust lists are optional, tenant-scoped, signed, versioned, activated/deactivated and auditable.
- A customer list may contain one or more customer root CAs and policy metadata.
- When present, customer trust is evaluated first.
- EU LOTL and national TLv6 are evaluated afterward for every validation requiring EU status.
- If no customer list exists, only the EU route is evaluated.
- Final status distinguishes:
  - `CUSTOMER_QUALIFIED` — qualified by customer policy, not eIDAS-qualified;
  - `EIDAS_QUALIFIED`;
  - `CUSTOMER_AND_EIDAS_QUALIFIED`;
  - `TRUSTED_NON_QUALIFIED`;
  - `UNTRUSTED`;
  - `INDETERMINATE`.
- Reports state the precise trust source and never infer eIDAS qualification from a private/customer root.

### 7.6 Revocation features

1. Validate the certificate path and determine the correct issuer.
2. Query OCSP using the certificate/issuer pair.
3. Validate the OCSP responder authorization, response signature, freshness, produced-at/this-update/next-update values and nonce policy.
4. Treat `GOOD` or `REVOKED` as conclusive according to policy.
5. If OCSP is unavailable, times out or returns `UNKNOWN`, retrieve the issuer's CRL from the X.509 CRL Distribution Point.
6. Validate CRL issuer, signature, scope, freshness, base/delta relationship and indirect-CRL rules when applicable.
7. Cache only validated evidence and retain the exact bytes/hash in the validation record.
8. There is no single worldwide CRL registry. “International CRL” means an issuer-published CRL reachable through public/international CA infrastructure.

## 8. Project phases

### Phase 0 — Baseline and safety net (1–2 weeks)

Although module separation is the first product change, a short safety phase is required before moving code.

**Tasks**

- Make the current reactor build from a clean checkout.
- Resolve or remove the missing `unichorn-isearch` dependency.
- Capture existing behavior with characterization tests.
- Create a corpus for signed/encrypted mail, certificates, PAdES/XAdES/CAdES/ASiC, OCSP, CRL and trust lists.
- Inventory all IAIK imports, dependencies, local JARs, keystores, certificates, passwords and signed resources.
- Generate an initial dependency tree, license report and CycloneDX SBOM.

**Exit criteria**

- Reproducible build, versioned test corpus, CI pipeline and complete IAIK migration inventory.

### Phase 1 — Separate modules first (3–5 weeks)

**Tasks**

- Create the target parent/aggregator POM and module skeletons.
- Extract domain records and exceptions without changing behavior.
- Introduce `unichorn-application-api` interfaces around current implementations.
- Move mail classes into `unichorn-mail-core`/`unichorn-mail-transport` without rewriting them yet.
- Move certificate, signature, trust, revocation and token packages behind their new APIs.
- Keep compatibility facades in `unichorn-core-legacy` temporarily so the old GUI continues to run.
- Add ArchUnit or Maven/JDeps rules to prevent forbidden dependency directions.

**Exit criteria**

- All modules compile; the old application still passes baseline tests; GUI code no longer owns business logic; module dependency rules are enforced.

### Phase 2 — Update libraries and build platform (2–4 weeks)

**Tasks**

- Select JDK 21 as the first migration baseline; test JDK 25 separately before adopting it.
- Centralize versions with dependency management/BOMs.
- Add Maven Enforcer, toolchains, reproducible builds, dependency convergence and duplicate-class checks.
- Remove JavaFX early-access and mixed JavaFX generations.
- Migrate to one Jakarta stack, one logging stack, one PDF strategy and Apache HttpClient 5.
- Replace JUnit 4, `mockito-all`, old PowerMock and ASM 3.
- Upgrade dependencies in small groups with a green test run after each group.
- Configure automated dependency-update proposals, but never auto-merge cryptographic upgrades.

**Exit criteria**

- Modern supported build, no convergence errors, no unexplained high/critical dependency finding, and unchanged baseline behavior.

### Phase 3 — Replace IAIK with Bouncy Castle and DSS (5–8 weeks)

**Migration order**

1. Provider bootstrap and generic JCA/JCE operations.
2. X.509, CSR, certificate and keystore utilities.
3. CMS and RFC 5751 S/MIME.
4. OCSP, CRL and timestamp primitives.
5. DSS validation and reports.
6. DSS signature creation.
7. DSS augmentation and EU trusted-list qualification.
8. Remove remaining IAIK TLS/XML/PDF/provider utilities.

**Rules**

- Use Bouncy Castle 1.85 as the initial current baseline.
- Use DSS 6.4 stable in production builds; run DSS 6.5.RC1 only in an allowed-failure compatibility lane until a stable release is approved.
- Never expose BC or DSS classes through application interfaces.
- Compare old/new results against the reference corpus and document every semantic difference.

**Exit criteria**

- End-to-end signature, certificate, S/MIME and revocation flows work without IAIK; repository and dependency-tree searches show no IAIK runtime dependency.

### Phase 4 — Specify and implement token/PKCS#11 support (3–5 weeks)

**Tasks**

- Approve the `unichorn-token-api` contract and threat model.
- Implement SunPKCS11 provider configuration without internal `sun.*` APIs.
- Integrate DSS `Pkcs11SignatureToken` behind the DSS adapter.
- Support certificate enumeration, alias/identity selection, signing and card-backed decrypt/unwrap where supported.
- Implement PIN callbacks, retry/lock reporting, session lifecycle, token removal and non-thread-safe-driver serialization.
- Create a compatibility matrix for each supported card, OS, architecture, driver, slot, algorithm and operation.
- Use SoftHSM/OpenSC or another approved simulator for CI; retain real-card acceptance tests as a controlled hardware test lane.

**Exit criteria**

- At least one supported real card and the CI token simulator can sign; S/MIME decryption is tested where the token exposes it; private keys never leave the token.

### Phase 5 — Define utilities and complete service features (4–6 weeks)

**Tasks**

- Implement the utilities in Section 7.1.
- Finalize command/query/result DTOs and error taxonomy.
- Implement signature creation, validation, security analysis and maintenance as independent services.
- Implement certificate creation and validation as independent services.
- Add bounded streaming and cancellation to all file/network operations.
- Produce JSON and human-readable reports from one canonical result model.

**Exit criteria**

- Every major use case is callable through a provider-neutral interface and has unit/contract tests without JavaFX.

### Phase 6 — Implement trust lists and revocation routing (3–5 weeks)

**Tasks**

- Implement the signed/versioned customer trust-list repository and administration service.
- Implement DSS LOTL/national TLv6 synchronization with verified cached snapshots.
- Implement customer-first then EU trust evaluation.
- Implement OCSP-first and CRL-fallback revocation handling.
- Add offline validation from a chosen evidence snapshot.
- Persist policy version, validation time, OCSP/CRL bytes or hashes, customer-list version and EU TL/LOTL snapshot with the result.

**Exit criteria**

- All trust classifications are covered by deterministic tests; a customer-qualified certificate is never reported as eIDAS-qualified unless DSS independently establishes that status.

### Phase 7 — Extract and complete the mail client (3–5 weeks)

**Tasks**

- Make `unichorn-mail-core`, `unichorn-mail-transport` and `unichorn-mail-smime` independently buildable.
- Implement RFC 5751 signing, encryption, signed-then-encrypted processing, verification and decryption.
- Integrate software-keystore and card-backed identities.
- Display cryptographic, revocation, customer-trust and eIDAS results independently.
- Implement safe HTML/attachment/link handling and secret storage.
- Create `unichorn-app-mail` with its own launcher, configuration and package.

**Exit criteria**

- Mail can send/read unsigned, signed, encrypted and signed-then-encrypted messages; interoperability tests pass with at least two independent S/MIME clients.

### Phase 8 — Build the separate GUIs (6–9 weeks)

Build in this order so reusable components stabilize early:

1. `unichorn-app-signature-validate`
2. `unichorn-app-certificate-validate`
3. `unichorn-app-trust-center`
4. `unichorn-app-signature-create`
5. `unichorn-app-certificate-create`
6. `unichorn-app-signature-maintenance`
7. `unichorn-app-mail`
8. Optional `unichorn-app-token-manager`

**GUI requirements**

- Thin JavaFX controllers calling application interfaces asynchronously.
- Explicit progress and cancellation for network/cryptographic operations.
- Consistent result colors without replacing detailed status text.
- Accessible keyboard navigation, scalable text and localization-ready labels.
- No PIN, password, certificate private material or message content in logs.
- Each GUI receives an independent `jlink`/`jpackage` runtime image.

**Exit criteria**

- Independent launchers and installers, no combined “god GUI,” and principal workflows covered by UI/integration tests.

### Phase 9 — External interfaces (3–5 weeks)

**Tasks**

- Add CLI commands for all approved services.
- Define a versioned REST/OpenAPI adapter only for workflows that require remote access.
- Separate responder endpoints for TSA, OCSP and administration.
- Add authentication, authorization, rate limiting, request-size limits, audit logging and idempotency where appropriate.
- Never transfer local private keys through the REST API; use digest/signature-value or remote-signing protocols through explicit adapters.

**Exit criteria**

- CLI and optional REST adapters pass the same contract tests as the GUIs; external interfaces expose no provider-specific types.

### Phase 10 — Hardening and release (2–4 weeks)

**Tasks**

- Run SAST, dependency, secret and license scans.
- Add fuzzing/property tests for ASN.1, MIME, XML, PDF and archive parsing.
- Enforce file-size, MIME-depth, decompression-ratio, network and execution-time limits.
- Generate an SBOM and sign release artifacts.
- Remove legacy compatibility facades and all IAIK configuration/resources.
- Publish supported-format, card, algorithm and interoperability matrices.
- Test rollback and migration of user configuration/trust lists.

**Exit criteria**

- Zero IAIK dependencies/imports, no unresolved critical/high issue without formal acceptance, reproducible signed packages and complete operator/user documentation.

## 9. Milestones and indicative schedule

| Milestone | Result | Phase duration | Cumulative range |
|---|---|---:|---:|
| M0 | Reproducible baseline and migration inventory | 1–2 weeks | 2 weeks |
| M1 | Module separation with legacy behavior preserved | 3–5 weeks | 5–7 weeks |
| M2 | Modern JDK/build/dependencies | 2–4 weeks | 7–11 weeks |
| M3 | IAIK replaced by BC/DSS vertical slices | 5–8 weeks | 12–19 weeks |
| M4 | PKCS#11/token abstraction working | 3–5 weeks | 15–24 weeks |
| M5 | Utilities and provider-neutral services complete | 4–6 weeks | 19–30 weeks |
| M6 | Customer/EU trust and revocation routing complete | 3–5 weeks | 22–35 weeks |
| M7 | Independent mail client complete | 3–5 weeks | 25–40 weeks |
| M8 | Separate GUI applications packaged | 6–9 weeks | 31–49 weeks |
| M9 | CLI/optional REST/responder interfaces | 3–5 weeks | 34–54 weeks |
| M10 | Hardened release | 2–4 weeks | **36–58 weeks** |

The cumulative figure assumes mostly sequential execution by a small team. After Phase 3, GUI, trust, token and mail workstreams can run partly in parallel if interface contracts and test fixtures are stable. Re-estimate after Phase 0 and again after the first DSS/PKCS#11 vertical slice.

## 10. Definition of done for every feature

A feature is complete only when:

- its provider-neutral interface and DTOs are documented;
- unit, contract, negative and interoperability tests pass;
- malformed and oversized inputs are tested;
- audit/evidence output is defined;
- secrets and private keys are not logged or exported;
- dependency and license scans pass;
- the feature works through at least one non-GUI adapter;
- GUI operations are cancellable and do not block the JavaFX thread;
- user documentation states security assumptions and limitations;
- migration and rollback behavior is documented.

## 11. Principal risks and mitigations

| Risk | Consequence | Mitigation |
|---|---|---|
| Large IAIK surface | Hidden behavioral differences | Complete import map, characterization corpus and vertical-slice migration |
| Simultaneous module/library/provider rewrite | Untraceable regressions | Preserve the phase order and keep every phase green |
| DSS/BC version incompatibility | Provider or validation failures | Pin compatible versions; use DSS BOM/dependency tree; compatibility CI |
| Card-driver differences | Token works on one OS/card only | Hardware compatibility matrix, simulator CI and real-card release gate |
| Incorrect “qualified” terminology | Customer trust mistaken for eIDAS status | Separate status enum and explicit UI/report wording |
| OCSP outage | False failure or unsafe acceptance | Policy-controlled CRL fallback and auditable `INDETERMINATE` outcome |
| Stale CRL/TL evidence | Incorrect historical/current result | Freshness rules, signed snapshots, validation-time model and cache metadata |
| Malicious documents/mail | Parser exploits or resource exhaustion | Bounded streaming, isolation, fuzzing, MIME/archive/PDF/XML limits |
| GUI split duplicates logic | Divergent behavior | Shared application services and contract tests; `ui-common` contains no business rules |
| Scope expansion | Release delay | Freeze promised formats/cards/GUIs per milestone and place additions in backlog |

## 12. Additional recommendations

1. Create architecture decision records for JDK baseline, DSS, Bouncy Castle, PKCS#11, trust routing, revocation policy and GUI packaging.
2. Treat private/customer CA functionality as a separate security domain from eIDAS qualification.
3. Use a single canonical `ValidationEvidenceBundle` so results can be replayed offline.
4. Introduce a plugin/service-provider mechanism only for key sources and optional policy packs; avoid a general plugin system during migration.
5. Add a compatibility dashboard covering formats, signature levels, algorithms, mail clients, cards, operating systems and trust routes.
6. Prefer one repository and one release train initially. Separate repositories only if teams and release cycles genuinely diverge.
7. Keep the responder optional. A desktop-only installation must not require a server.
8. Publish a security policy and a documented process for algorithm-policy and trust-list emergency updates.

## 13. First implementation backlog

The first actionable backlog should be:

1. Make the current Maven build reproducible.
2. Resolve `unichorn-isearch`.
3. Generate IAIK import/dependency inventory.
4. Build the test corpus and characterization tests.
5. Create new parent POM and module skeletons.
6. Define `unichorn-domain` and `unichorn-application-api` dependency rules.
7. Extract mail, signature, certificate, trust and token packages without changing behavior.
8. Add compatibility facades so the old GUI still runs.
9. Select and document the JDK/JavaFX baseline.
10. Start controlled dependency upgrades.
11. Implement `CryptoProviderBootstrap` with Bouncy Castle 1.85.
12. Deliver one vertical slice: certificate load → path validation → OCSP/CRL → customer/EU trust report.
13. Deliver a second vertical slice: RFC 5751 signed/encrypted mail using software keys.
14. Deliver a third vertical slice: DSS validation/reporting.
15. Deliver a fourth vertical slice: card-backed signing through the new token API.

## 14. Primary technical references

- European Commission DSS 6.4: <https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/952471879/DSS+v6.4>
- DSS 6.5.RC1 compatibility target: <https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/973932532/DSS+v6.5.RC1>
- DSS `Pkcs11SignatureToken` API: <https://ec.europa.eu/digital-building-blocks/DSS/webapp-demo/apidocs/eu/europa/esig/dss/token/Pkcs11SignatureToken.html>
- Bouncy Castle Java 1.85: <https://www.bouncycastle.org/resources/new-release-bouncy-castle-java-1-85/>
- Java PKCS#11 Reference Guide: <https://docs.oracle.com/en/java/javase/26/security/pkcs11-reference-guide1.html>
- Eclipse Angus Mail: <https://github.com/eclipse-ee4j/angus-mail>
- OpenJFX: <https://openjfx.io/>
- RFC 5751, S/MIME 3.2: <https://www.rfc-editor.org/rfc/rfc5751>
- RFC 8551, S/MIME 4.0: <https://www.rfc-editor.org/rfc/rfc8551>


- Harald Glab-Plhak
- Computer Science since 1992
- &copy; Harald Glab-Plhak (2026)
