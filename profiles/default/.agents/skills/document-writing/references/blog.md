# Blog Articles

## Voice and structure

For new Korean articles, use a conversational polite style ending in `~해요` and first-person `저`, not `나` or `필자`. Keep it natural rather than appending rhetorical questions or greetings to every section. Light humor is optional; do not manufacture reactions or add decorative emoji by default.

Open with why the topic matters or why the author undertook the work. Develop the actual process, choices, results, and tradeoffs, then close with a useful summary, limitations, or next steps. A `마치며` section suits longer articles; short pieces need not mechanically repeat the same structure. Use `##` sections and `###` subsections for new articles, with `* * *` between major sections where useful. Preserve an existing article's heading hierarchy during narrow edits.

Maintain an experience-led, candid voice only where experience was actually supplied. Explain alternatives and disadvantages when relevant and supported, not as invented mandatory counterpoints. Use short paragraphs and restrained emphasis. Put commands, paths, and identifiers in backticks, rather than marking every product name as code.

## Sources and images

Link relevant products, tools, documentation, and evidence inline with descriptive text. Do not automatically append `?ref=tinyrack.net` to new URLs; preserve existing intentional referral parameters and add them only when requested or required by the publication's established configuration.

Use real images near the explanation they support, with relative paths such as `![Product ports](./attachments/product-ports.png)`. Preserve existing image embeds during scoped edits. If an image is needed but unavailable, identify it as missing rather than inserting a broken link or pretending it exists.

## Metadata and translations

Inspect the current article and publication conventions before creating or changing frontmatter. Preserve existing fields, including publisher-specific fields such as `commentsTerm` and `draft`, and do not normalize legacy metadata as part of a prose edit.

The existing article schema uses:

| Field | Meaning and handling |
| --- | --- |
| `title` | Article title in this language |
| `excerpt` | Concise summary, normally two to four short sentences |
| `lang` | Language of this file: `ko`, `en`, or `ja` |
| `routeSlug` | Publication route; preserve established values |
| `translationKey` | Shared identifier across all translations |
| `featureImage` | Actual representative image, usually under `./attachments/` |
| `updatedAt` | Actual editorial update time when required by the publication |
| `publishedAt` | Actual publication time, not the time a draft was generated |
| `tags` | Relevant tags following the destination's vocabulary |

For new drafts, set known descriptive fields and follow the destination's draft convention. Do not invent publication dates or image paths to fill the schema. If a publishing workflow requires missing information, surface it before publication. Preserve original publication dates on revisions.

Use `ko.md` as the source for this user's multilingual articles unless directed otherwise. Create or update `en.md` and `ja.md` only within the requested translation scope. Keep `translationKey`, facts, code semantics, and asset references consistent, while using idiomatic local wording rather than literal translation. Do not silently treat existing translations as updated when only Korean changed.

## Review

Check natural voice, supported personal claims, useful technical detail, relevant limitations, valid links/images, and consistent metadata. A completed draft is not automatically published or moved to `Completed`.
