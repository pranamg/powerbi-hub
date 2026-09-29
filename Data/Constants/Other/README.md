# Other Constants

> Shared definitions that do not fit the other constant folders.

## Appropriate content

- Static lookup tables used for mapping, such as status codes or category
  hierarchies.
- Reusable format strings for measures that are awkward to express inline.
- Parameter tables shared across models.

## Guidance

A constant earns its place here if more than one model uses it. If it is used
once, keep it in the model that needs it — a shared folder is not a substitute
for a sensible home.

Document what each constant is and when to prefer it, since a table of
abbreviations with no explanation tends to be copied blindly.

## Related

- [ColorTable](../ColorTable/)
- [DateTable](../DateTable/)
- [Data constants folder](../)
