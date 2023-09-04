// Auto-imported filters by 'gmailctl download'.
//
// WARNING: This functionality is experimental. Before making any
// changes, check that no diff is detected with the remote filters by
// using the 'diff' command.

// Uncomment if you want to use the standard library.
// local lib = import 'gmailctl.libsonnet';
{
  version: "v1alpha3",
  author: {
    name: "YOUR NAME HERE (auto imported)",
    email: "your-email@gmail.com"
  },
  // Note: labels management is optional. If you prefer to use the
  // GMail interface to add and remove labels, you can safely remove
  // this section of the config.
  labels: [
    {
      name: "gcal"
    },
    {
      name: "reply-soon"
    },
    {
      name: "Networking"
    },
    {
      name: "Someday-Maybe",
      color: {
        background: "#fdedc1",
        text: "#684e07"
      }
    },
    {
      name: "[Superhuman]"
    },
    {
      name: "[Superhuman]/ru"
    },
    {
      name: "[Superhuman]/Muted"
    },
    {
      name: "[Superhuman]/Is Snoozed"
    },
    {
      name: "open-source"
    },
    {
      name: "Purchases"
    }
  ],
  rules: [
    {
      filter: {
        query: "list:email.superhuman.com"
      },
      actions: {
        markSpam: false,
        markImportant: true,
        category: "personal"
      }
    },
    {
      filter: {
        query: "subject:(\"invitation\" OR \"accepted\" OR \"rejected\" OR \"updated\" OR \"canceled event\" OR \"declined\" OR \"proposed\") when where calendar who organizer"
      },
      actions: {
        archive: true,
        star: true,
        markImportant: false,
        category: "updates"
      }
    },
    {
      filter: {
        query: "category:Updates OR category:promotions OR category:Social"
      },
      actions: {
        archive: true,
        star: true,
        markImportant: false
      }
    }
  ]
}
