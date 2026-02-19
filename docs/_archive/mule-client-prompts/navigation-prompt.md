# Navigation Addition Prompt

Use this prompt when asking AI to add new navigation items:

---

**CRITICAL: Follow these exact steps for navigation changes:**

1. **Check existing translation system**: The app uses `react-i18next` with keys in `/src/lib/i18n.ts`

2. **Add translation keys FIRST** to `/src/lib/i18n.ts`:
   ```js
   'nav.sectionname': 'Section Name',
   'nav.itemname': 'Item Name'
   ```

3. **Update navigation config** in `/src/layouts/nav-config-dashboard.tsx`

4. **Add routes** to `/src/routes/paths.ts`

5. **Create page files** in `/src/app/dashboard/`

6. **Use correct translation hook**: `useTranslation` from `react-i18next`

7. **IMPORTANT - Component Imports**: Use only existing components:
   - `DashboardContent` from `src/layouts/dashboard`
   - Standard MUI components: `Typography`, `Table`, `TableBody`, `TableCell`, `TableHead`, `TableRow`, `Paper`
   - DO NOT use: `CustomBreadcrumbs`, `useTable`, `TableHeadCustom` (these don't exist)

**VERIFY**: Translation keys exist before using them. Test navigation displays text, not variable names.

---

Copy this prompt when requesting navigation changes to prevent i18n and import issues.
