# Supabase cloud setup

1. Create a Supabase project.
2. Open **SQL Editor** and run migrations in filename order. Existing projects must also run `migrations/202609090001_integrated_chores_settlements.sql` to enable structured member, weekly chore, and settlement archive synchronization.
3. In **Authentication → Users**, create the household owner's email/password account (or enable email signup).
4. This build is preconfigured for project `qjcucjjjpnezimzcefom` and its browser-safe publishable key. Never substitute a secret or service-role key in client code.
5. In the app, open **Admin → Supabase Cloud Sync**, enter those values and the owner credentials, then choose **Save & Sign In**.
6. Choose **Upload Current Device State** for the first sync. Enable automatic upload only after verifying the manual upload.

The owner password is never stored. The access token is kept in `sessionStorage`, so the owner signs in again after the app/browser session ends. Local participant passwords are deliberately excluded from cloud snapshots.
