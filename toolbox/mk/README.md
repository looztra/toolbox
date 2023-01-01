# Local vs Remote mk targets

## What?

- In order to `reuse` mk target/include files instead of copying them, you can find here the reference of mk include files that can be downloaded
- The `remote-mk.mk` contains the logic to automatically donwload remote mk files
- The other `.mk` files are the one you can download

## Usage

### Setup

- You have to **copy** the `remote-mk.mk` to the directory when you want to use/download the other mk files (you cannot download the code that says how to download the code :D)
- Then use a `Makefile` like this one:

```Makefile
#
MK_ACTIONLINT_SHA256          := fbbf3b567ac9854481cf32274f480c501f093d9436151e50d584ed89bc2afdcc
MK_COMMON_SHA256              := 2d49615c5fa43b30d739e4a00c175fc7f295665c9a01f32a52792f6aa80a3bfa
MK_DOCKER_SHA256              := 8dddb0f5b71d24b4b205a36f514aa7c9ddd4ca771557694e6d1410c5fbbdf8f2
MK_PRE_COMMIT_SHA256          := 0c73900d816a266dfaa230b3223f25f53caff97d102e8fced7dbab997c2a46f1
MK_PYTHON_POETRY_APP_SHA256   := 65204fedf5a5bfe1915f55b2af9414f9aa65e26d0c0da84a695964ded8129b48
MK_PYTHON_POETRY_VENV_SHA256  := d47a786cb9264ee5533120ce0b32067ac0babd9857ee25cc60618be7521b4342
#
MK_GIT_REF ?= mk-0.1.0

# local mk that MUST BE declared **first**
include mk/remote-mk.mk

# remote mk
include generated/mk/common.mk
include generated/mk/actionlint.mk
include generated/mk/pre-commit.mk
include generated/mk/python-poetry-venv.mk
include generated/mk/python-poetry-app.mk
include generated/mk/docker.mk
```

And that's it!

The remote/included mk files will be downloaded if:

- they do not exist locally
- you changed the `MK_GIT_REF` tag to use or the _SHA256 value
- you changed something else in the `Makefile`

### Github action

- When your project is using remote mk and you CI too, you need to add a step that downloads the remote mk files before any other calls to make targets

```yaml
      - name: Ensure remote mk targets are present
        run: |
          make init-mk
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Tips

### Compute the sha256 sum of shared mk files

- Bash/Zsh:

```bash
for mk_file in $(ls *.mk | grep -v remote-mk); do
  printf "%-29s := %s\n" MK_$(echo $mk_file | cut -d '.' -f1 | tr '[:lower:]' '[:upper:]' | tr '-' '_')_SHA256 $(sha256sum $mk_file | cut -d " " -f1)
done
```

- Fish:

```fish
for mk_file in (ls *.mk | grep -v remote-mk)
  printf "%-29s := %s\n" MK_(echo $mk_file | cut -d '.' -f1 | tr '[:lower:]' '[:upper:]' | tr '-' '_')_SHA256 (sha256sum $mk_file | cut -d " " -f1)
end
```
