# LAA Crime Forms Common
This is a gem and npm package that is used to share functionality and data across the 'Submit a crime form' and 'Assess a crime form' services.

It is currently used for:

- Shared L10n of strings
- JSON schema definition and validation
- Pricing and fees

It may one day be used for:

- Shared logic relating to the LAA crime application store including:
  - Generating tokens to authenticate outgoing requests
  - Verifying tokens on incoming requests
  - Webhook subscription/unsubscription
- Shared UI components
- Shared search functionality
- And more

## NPM Package
For instances where we only want to share a JS function, this code is stored in the [node package](https://www.npmjs.com/package/laa-crime-forms-common) of this directory. All files for this node package are in the js folder to prevent mixing with the gem.

## Licence
Unless stated otherwise, the codebase is released under the [MIT License][mit].

[mit]: LICENCE

