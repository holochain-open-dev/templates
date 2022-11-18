#!/usr/bin/bash
set -e

rm -rf /tmp/forum-lit-open-dev

hc-scaffold web-app forum-lit-open-dev --setup-nix true --template app --templates-path .templates

mv forum-lit-open-dev /tmp
cd /tmp/forum-lit-open-dev
hc-scaffold dna forum 

hc-scaffold zome posts --integrity dnas/forum/zomes/integrity/ --coordinator dnas/forum/zomes/coordinator/
hc-scaffold entry-type post --fixed false --crud crud --link-from-original-to-each-update true --depends-on --depends-on-itself false --fields
hc-scaffold entry-type comment --fixed false --crud crud --link-from-original-to-each-update false --depends-on post --depends-on-itself false --fields
hc-scaffold entry-type like --fixed false --crud crd --depends-on --depends-on-itself option --fields
hc-scaffold entry-type certificate --fixed true --crud cr --depends-on post,agent:certified --depends-on-itself vector --fields

hc-scaffold index global all_posts post 
hc-scaffold index by-author posts_by_author post
hc-scaffold index global all_posts_entry_hash post:EntryHash
hc-scaffold index by-author posts_by_author_entry_hash post:EntryHash

hc-scaffold link-type post like --bidireccional false
hc-scaffold link-type comment like:EntryHash --bidireccional true
hc-scaffold link-type certificate:EntryHash like --bidireccional false
hc-scaffold link-type agent:Creator post:EntryHash --bidireccional true

hc-scaffold zome profiles --coordinator dnas/forum/zomes/coordinator --integrity dnas/forum/zomes/integrity
cargo add -p profiles --git https://github.com/holochain-open-dev/profiles hc_zome_profiles_coordinator
echo "extern crate hc_zome_profiles_coordinator;" > dnas/forum/zomes/coordinator/profiles/src/lib.rs
cargo add -p profiles_integrity --git https://github.com/holochain-open-dev/profiles hc_zome_profiles_integrity
echo "extern crate hc_zome_profiles_integrity;" > dnas/forum/zomes/integrity/profiles/src/lib.rs

nix-shell . --run "
set -e
npm i
npm run build -w ui
npm run lint -w ui
"
