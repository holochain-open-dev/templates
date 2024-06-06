#!/usr/bin/bash
set -e

DIR=$(pwd)

nix shell --accept-flake-config .#hc-scaffold-zome-template --command bash -c "
cd /tmp
rm -rf posts-open-dev
mkdir posts-open-dev
cd posts-open-dev

hc-scaffold web-app posts --setup-nix true -F 
"

cd /tmp/posts-open-dev/posts

nix develop --accept-flake-config --override-input scaffolding "path:$DIR" --command bash -c "
set -e

hc-scaffold entry-type post --zome posts_integrity --reference-entry-hash false --crud crud --link-from-original-to-each-update true --fields title:String:TextField,needs:Vec\<String\>:TextField
hc-scaffold entry-type comment --zome posts_integrity  --reference-entry-hash false --crud crud --link-from-original-to-each-update false --fields post_hash:ActionHash::Post
hc-scaffold entry-type like --zome posts_integrity  --reference-entry-hash false --crud crd --fields like_hash:Option\<ActionHash\>::Like,agent:AgentPubKey:SearchAgent
hc-scaffold entry-type certificate --zome posts_integrity  --reference-entry-hash false --crud cr --fields post_hash:ActionHash::Post,agent:AgentPubKey::certified,certifications_hashes:Vec\<EntryHash\>::Certificate,certificate_type:Enum::CertificateType:TypeOne.TypeTwo,dna_hash:DnaHash

hc-scaffold collection --zome posts_integrity global all_posts post 
hc-scaffold collection --zome posts_integrity by-author posts_by_author post
hc-scaffold collection --zome posts_integrity global all_posts_entry_hash post:EntryHash
hc-scaffold collection --zome posts_integrity by-author posts_by_author_entry_hash post:EntryHash

hc-scaffold link-type --zome posts_integrity post like --delete true --bidirectional false
hc-scaffold link-type --zome posts_integrity comment like --delete true --bidirectional false
hc-scaffold link-type --zome posts_integrity certificate like --delete false --bidirectional false
hc-scaffold link-type --zome posts_integrity agent:creator post --delete false --bidirectional false

git add .

pnpm i

pnpm -F @holochain-open-dev/posts format
pnpm -F @holochain-open-dev/posts lint
pnpm -F @holochain-open-dev/posts build

pnpm i

pnpm build:happ
pnpm -F tests test
"
