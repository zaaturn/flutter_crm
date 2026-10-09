{{flutter_js}}
{{flutter_build_config}}

// Fonts and images are served from a folder named after the deploy
// (/v/<commit>/assets/, see .github/workflows/deploy.yml). Flutter reuses the
// same file names on every build, and Firebase caches /assets for a year, so
// without this a browser keeps last month's icon font and new icons show up
// blank. Local builds leave the placeholder as-is and load from assets/.
(function () {
  var assetBase = "__ASSET_BASE__";
  var versioned = assetBase.indexOf("__") !== 0;
  _flutter.loader.load(versioned ? { config: { assetBase: assetBase } } : undefined);
})();
