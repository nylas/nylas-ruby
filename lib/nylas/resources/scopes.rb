module Nylas
  module ProviderScopes
    SCOPES = {
      google: {
        # OAuth2 API v2 (https://developers.google.com/identity/protocols/oauth2/scopes#oauth2)
        open_id: "openid",
        user_info: {
          # View your email address
          email: "https://www.googleapis.com/auth/userinfo.email",
          # See your personal info, including any personal info you've made publicly available
          profile: "https://www.googleapis.com/auth/userinfo.profile"
        },
        # GMail API v1 (https://developers.google.com/identity/protocols/oauth2/scopes#gmail)
        gmail: {
          # Read, compose, send, and permanently delete all your email from Gmail
          all: "https://mail.google.com/",
          add_ons: {
            current: {
              # Manage drafts and send emails when you interact with the add-on
              action_compose:
                "https://www.googleapis.com/auth/gmail.addons.current.action.compose",
              # View your email messages when you interact with the add-on
              message_action:
                "https://www.googleapis.com/auth/gmail.addons.current.message.action",
              # View your email message metadata when the add-on is running
              message_metadata:
                "https://www.googleapis.com/auth/gmail.addons.current.message.metadata",
              # View your email messages when the add-on is running
              message_readonly:
                "https://www.googleapis.com/auth/gmail.addons.current.message.readonly"
            }
          },
          # Manage drafts and send emails
          compose: "https://www.googleapis.com/auth/gmail.compose",
          # Insert mail into your mailbox
          insert: "https://www.googleapis.com/auth/gmail.insert",
          # Manage mailbox labels
          labels: "https://www.googleapis.com/auth/gmail.labels",
          # View your email message metadata such as labels and headers, but not the email body
          metadata: "https://www.googleapis.com/auth/gmail.metadata",
          # View and modify but not delete your email
          modify: "https://www.googleapis.com/auth/gmail.modify",
          # View your email messages and settings
          readonly: "https://www.googleapis.com/auth/gmail.readonly",
          # Send email on your behalf
          send: "https://www.googleapis.com/auth/gmail.send",
          settings: {
            # Manage your basic mail settings
            basic: "https://www.googleapis.com/auth/gmail.settings.basic",
            # Manage your sensitive mail settings, including who can manage your mail
            sharing: "https://www.googleapis.com/auth/gmail.settings.sharing"
          }
        },
        # Calendar API v3 (https://developers.google.com/identity/protocols/oauth2/scopes#calendar)
        calendar: {
          # See, edit, share, and permanently delete all the calendars you can access using Google Calendar
          all: "https://www.googleapis.com/auth/calendar",
          # View and edit events on all your calendars
          events: "https://www.googleapis.com/auth/calendar.events",
          # View events on all your calendars
          events_readonly:
            "https://www.googleapis.com/auth/calendar.events.readonly",
          # See and download any calendar you can access using your Google Calendar
          readonly: "https://www.googleapis.com/auth/calendar.readonly",
          # View your Calendar settings
          settings_readonly:
            "https://www.googleapis.com/auth/calendar.settings.readonly",
          # View calendar room resources
          admin_directory_resource_calendar_readonly:
            "https://www.googleapis.com/auth/admin.directory.resource.calendar.readonly"
        },
        # See, edit, download, and permanently delete your contact
        contacts: "https://www.google.com/m8/feeds",
        # Contacts API v3 (https://developers.google.com/identity/protocols/oauth2/scopes#contacts)
        contacts_scopes: {
          # View your contacts
          readonly: "https://www.googleapis.com/auth/contacts.readonly"
        },
        # Drive API v3 (https://developers.google.com/identity/protocols/oauth2/scopes#drive)
        drive: {
          # See, edit, create, and delete all of your Google Drive files
          all: "https://www.googleapis.com/auth/drive",
          # View and manage Google Drive files and folders that you have opened or created with this app
          appData: "https://www.googleapis.com/auth/drive.appdata",
          # View and manage Google Drive files and folders that you have opened or created with this app
          file: "https://www.googleapis.com/auth/drive.file",
          # View and manage metadata of files in your Google Drive
          metadata: "https://www.googleapis.com/auth/drive.metadata",
          # View metadata for files in your Google Drive
          metadata_readonly:
            "https://www.googleapis.com/auth/drive.metadata.readonly",
          # View the photos, videos and albums in your Google Photos
          photos_readonly: "https://www.googleapis.com/auth/drive.photos.readonly",
          # View the files in your Google Drive
          readonly: "https://www.googleapis.com/auth/drive.readonly",
          # Modify your Google Apps Script scripts' behavior
          scripts: "https://www.googleapis.com/auth/drive.scripts"
        }
      },
      microsoft: {
        # OAuth2  (https://docs.microsoft.com/en-us/graph/permissions-reference#openid-connect-oidc-permissions)
        oauth2: {
          # Allows the app to read your users' primary email address.
          email: "email",
          # Allows users to sign in to the app with their work or school accounts and allows the app to see basic user profile information.
          openid: "openid",
          # Allows the app to see your users' basic profile (name, picture, user name).
          profile: "profile",
          # Allows the app to read and update user data, even when they are not currently using the app.
          offline_access: "offline_access"
        },
        # Mail (https://docs.microsoft.com/en-us/graph/permissions-reference#mail-permissions)
        mail: {
          # Allows the app to read email in user mailboxes.
          read: "Mail.Read",
          # Allows the app to read email in the signed-in user's mailbox, except for body, bodyPreview, uniqueBody, attachments, extensions, and any extended properties. Does not include permissions to search messages.
          read_basic: "Mail.ReadBasic",
          # Allows the app to create, read, update, and delete email in user mailboxes. Does not include permission to send mail.
          read_write: "Mail.ReadWrite",
          # Allows the app to read mail that the user can access, including the user's own and shared mail.
          read_shared: "Mail.Read.Shared",
          # Allows the app to create, read, update, and delete mail that the user has permission to access, including the user's own and shared mail. Does not include permission to send mail.
          read_write_shared: "Mail.ReadWrite.Shared",
          # Allows the app to send mail as users in the organization.
          send: "Mail.Send",
          # Allows the app to send mail as the signed-in user, including sending on-behalf of others.
          send_shared: "Mail.Send.Shared",
          mailbox_settings: {
            # Allows the app to the read user's mailbox settings. Does not include permission to send mail.
            read: "MailboxSettings.Read",
            # Allows the app to create, read, update, and delete user's mailbox settings. Does not include permission to directly send mail, but allows the app to create rules that can forward or redirect messages.
            read_write: "MailboxSettings.ReadWrite"
          },
          IMAP: {
            # Allows the app to read, update, create and delete email in user mailboxes. Does not include permission to send mail
            access_as_user_all: "IMAP.AccessAsUser.All"
          },
          POP: {
            # Allows the app to read, update, create and delete email in user mailboxes. Does not include permission to send mail.
            access_as_user_all: "POP.AccessAsUser.All"
          },
          SMTP: {
            # Allows the app to send mail as users in the organization.
            send: "SMTP.Send"
          }
        },
        contacts: {
          # Allows the app to read user contacts.
          read: "Contacts.Read",
          # Allows the app to read contacts that the user has permissions to access, including the user's own and shared contacts.
          read_shared: "Contacts.Read.Shared",
          # Allows the app to create, read, update, and delete user contacts.
          read_write: "Contacts.ReadWrite",
          # Allows the app to create, read, update and delete contacts that the user has permissions to, including the user's own and shared contacts.
          read_write_shared: "Contacts.ReadWrite.Shared"
        },
        user: {
          # Allows users to sign-in to the app, and allows the app to read the profile of signed-in users. It also allows the app to read basic company information of signed-in users.
          read: "User.Read",
          # Allows the app to read the signed-in user's full profile. It also allows the app to update the signed-in user's profile information on their behalf.
          read_write: "User.ReadWrite",
          # Allows the app to read a basic set of profile properties of other users in your organization on behalf of the signed-in user. This includes display name, first and last name, email address, open extensions and photo. Also allows the app to read the full profile of the signed-in user.
          read_basic: "User.ReadBasic.All",
          # Allows the app to read the full set of profile properties, reports, and managers of other users in your organization, on behalf of the signed-in user.
          read_all: "User.Read.All",
          # Allows the app to read and write the full set of profile properties, reports, and managers of other users in your organization, on behalf of the signed-in user. Also allows the app to create and delete users as well as reset user passwords on behalf of the signed-in user.
          read_write_all: "User.ReadWrite.All",
          # Allows the app to invite guest users to your organization, on behalf of the signed-in user.
          invite_all: "User.Invite.All",
          # Allows the app to export an organizational user's data, when performed by a Company Administrator.
          export_all: "User.Export.All",
          # Allows an application to read, update and delete identities that are associated with a user's account, that the signed-in user has access to. This controls which identities your users can sign-in with.
          manage_identities: "User.ManageIdentities.All"
        },
        calendar: {
          # Allows the app to read calendars and events in user's account.
          read: "Calendars.Read",
          # Allows the app to read calendars and events that the user can access, including the user's own and shared calendars.
          read_shared: "Calendars.Read.Shared",
          # Allows the app to create, read, update, and delete calendars and events in user's account.
          read_write: "Calendars.ReadWrite",
          # Allows the app to create, read, update, and delete calendars and events that the user can access, including the user's own and shared calendars.
          read_write_shared: "Calendars.ReadWrite.Shared",
          # Allows the app to read calendar room resources
          place_read_all: "Place.Read.All"
        },
        online_meetings: {
          # Allows an app to create, read online meetings on behalf of the signed-in user.
          read_write: "OnlineMeetings.ReadWrite"
        },
        # Allows default scope for everything not specifically defined
        default: "https://graph.microsoft.com/.default",
        EAS: {
          access_as_user_all: "EAS.AccessAsUser.All"
        },
        EWS: {
          access_as_user_all: "EWS.AccessAsUser.All"
        }
      },
      yahoo: {
        email: "email",
        profile: "profile",
        mail: {
          read: "mail-r",
          write: "mail-w"
        },
        contacts: {
          read: "sdct-r",
          write: "sdct-w"
        },
        calendar: {
          read: "ycal-r",
          write: "ycal-w"
        }
      }
    }.freeze
  end
end
