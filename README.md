# Throwpass
Easily and safely transport passwords from your phone to a shared computer.

See it in action at https://throwpass.com

Currently only the website code is up. The Android app code is coming soon.

Currently node.js is not handling the https. At the time I started this, node.js did not support any type of forward secrecy. So I have nginx applying https and forwarding the raw traffic to node.js.
