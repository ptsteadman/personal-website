ocuroot("0.3.0")

def repo_url():
    env_vars = env()
    if "GH_TOKEN" not in env_vars:
        return host.shell("git remote get-url origin").stdout.strip()
    # Always use https for checkout with GitHub actions
    return "https://x-access-token:{}@github.com/ptsteadman/personal-website.git".format(env_vars["GH_TOKEN"])

remote = repo_url()

remotes([remote])

store.set(
    store.git(remote, branch="state"),
    intent=store.git(remote, branch="intent")
)