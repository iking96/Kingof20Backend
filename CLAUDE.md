# King of 20

## Cleanup Rules
- After moving or refactoring code, delete any files/components that are no longer used
- Remove unused imports
- Don't leave orphaned files behind

## Style Preferences
- Avoid box-shadow by default. It can be used when it clearly enhances the design, but should not be the go-to choice.

## Future Tech Debt
- **Bundler upgrade**: Currently using Webpacker 5 / Webpack 4 which doesn't transpile node_modules by default. Modern packages ship ES2020+ syntax. Had to add `@babel/plugin-proposal-nullish-coalescing-operator` to support `react-dnd-multi-backend`. Consider migrating to Vite or Webpack 5 for better modern package support.
