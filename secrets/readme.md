# Managing Secrets with sops-nix

This repo uses [sops-nix](https://github.com/Mic92/sops-nix) to encrypt secrets at rest in the git repo and decrypt them into `/run/secrets/` at boot. Encryption is done with [age](https://github.com/FiloSottile/age). Each host has its own age keypair; a secret can only be decrypted by a host whose public key is listed in `.sops.yaml`.

---

## Prerequisites

You need `sops` and `age` available. On any host managed by this repo they are already in the nix store. If for some reason they are not on PATH, find them:

```sh
nix shell -p sops age
```

Your host's age private key lives at:

```
~/.config/sops/age/keys.txt
```

sops-nix auto-generates this on first build if it does not exist.

---

## Adding a new secret to an existing file

1. Open the secrets file for editing (sops decrypts it in your editor, re-encrypts on save):

```sh
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt sops secrets/secrets.yaml
```

2. Add your new key/value pair in plain text, e.g.:

```yaml
my_new_secret: "the-value-goes-here"
```

3. Save and close. sops re-encrypts the whole file automatically.

4. Declare the secret in your NixOS config so sops-nix decrypts it at boot:

```nix
sops.secrets.my_new_secret = { };
```

5. Reference the decrypted file at runtime via:

```nix
config.sops.secrets.my_new_secret.path   # evaluates to /run/secrets/my_new_secret
```

6. Commit and push.

---

## Creating a brand-new secrets file

1. Make sure `.sops.yaml` has a `creation_rules` entry whose `path_regex` matches your intended filename. The existing rules cover `secrets/*.yaml` and `secrets/*.json` — if your file fits one of those, skip this step.

2. Create and open the file (sops encrypts it on first save):

```sh
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt sops secrets/new-file.yaml
```

3. Add your secrets, save, commit, push.

---

## Adding a new host to the encryption

When you set up a new machine you need to add its age public key so it can decrypt the existing secrets.

1. On the **new host**, get its public key:

```sh
grep "# public key:" ~/.config/sops/age/keys.txt
```

   If the key file does not exist yet, run a build first (`nh nixos switch`) — sops-nix will generate it.

2. Open `.sops.yaml` (at the repo root) and add the key under `keys:` with a YAML anchor:

```yaml
keys:
  - &existing-host age1...
  - &new-host age1...          # <-- add this line
```

3. Add the anchor to every `key_groups` list in `creation_rules`:

```yaml
creation_rules:
  - path_regex: secrets/[^/]+\.ya?ml$
    key_groups:
      - age:
          - *existing-host
          - *new-host            # <-- add this line
```

   Repeat for every rule block (yaml, json, etc.).

4. Sync the recipients in every existing secrets file to match `.sops.yaml`. This **must** be done from a host that already has a working decryption key (i.e. a host whose key is already in the file):

```sh
sops updatekeys --yes secrets/secrets.yaml
```

   Repeat for any other secrets files in the directory. Note: `sops -r` (rotate) does **not** add new recipients — it only rotates the data encryption key. Use `updatekeys`.

5. Commit and push. Pull on the new host and rebuild.

---

## Gotchas

- **`sops updatekeys` must be run from a host that can already decrypt.** If you add a new host's key but only have that new host's private key, `updatekeys` will fail. Do it from an existing host.
- **`validateSopsFiles = false`** is set in `modules/base/nixos/sops.nix`. This means the build will not fail if a secret cannot be decrypted — but the secret simply will not appear in `/run/secrets/` at runtime. If a service needs it, it will fail silently or crash.
- **Per-host secrets** are possible by scoping `path_regex` in `.sops.yaml` to a subdirectory (e.g. `secrets/hpl-tower/`) and only listing that host's key in that rule.
- **The default secrets file** is set in `sops.nix` via `sops.defaultSopsFile`. Any secret declared with `sops.secrets.<name> = { };` (no explicit `sopsFile`) is read from that file.
