```
kube-prune.sh [-h | --help] [-n | --namespace <namespace>] [-t | --time <time>] [-p | --pattern <pattern>] [--confirm-deletion]

Filter pods by namespace, matching a pattern, or older than a given time, then delete them.
Uses kubectl. Make sure kubectl is installed, and that you can list your pods with `kubectl get pods --all-namespaces`.

Pods are deleted only when you specify --confirm-deletion, be sure you want to delete all listed pods.
It is safe to use this script without --confirm-deletion.

Usage:
-h,--help           show this help text.
-n,--namespace      set namespace, expects a string.
-t,--time           list pods older than the time given, expects a string like 10s (10 seconds), 30m (30 minutes), 2h (2 hours) or 1d (one day).
-p,--pattern        list pods matching a pattern, expects a string or a RegExp.
--confirm-deletion  Delete pods. Be careful when using it!
```
