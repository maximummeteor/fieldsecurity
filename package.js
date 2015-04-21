Package.describe({
  name: "maxnowack:collection-security",
  summary: "Meteor package that provides a simple way to define security rules for collections",
  version: "0.1.0",
  git: "https://github.com/maxnowack/meteor-collection-security"
});

Package.onUse(function(api) {
  api.versionsFrom("1.0.1");
  api.use(["coffeescript"]);

  api.addFiles("server/collection-security.coffee", ["server"]);
});


Package.onTest(function (api) {
  api.use("tinytest");
  api.use("coffeescript");
  api.use("maxnowack:collection-security");

  api.addFiles("tests/collection-security.coffee");

});
