# UI Component Design: Dynamic Form Builder

## Overview
Design and implement a comprehensive, reusable, data-driven form component for the `@asyml8/ui` package that supports dynamic field generation, advanced validation, responsive layouts, and complex form controls.

## Requirements

### Core Principles
- **Data-driven**: Forms defined entirely by JSON configuration
- **Type-safe**: Full TypeScript support with proper type inference
- **Reusable**: Works across all applications in the monorepo
- **Responsive**: Auto-layout with configurable grid system
- **Accessible**: WCAG 2.1 AA compliant
- **Modern**: Uses latest React patterns (hooks, context, suspense)

### Technical Stack
- **Form State**: React Hook Form v7+ with Controller pattern
- **Validation**: Zod schemas with dynamic schema generation
- **UI Framework**: Material-UI v5+ components
- **Layout**: CSS Grid/Flexbox with MUI Grid system
- **TypeScript**: Strict mode with proper type inference

### Supported Form Controls

#### Basic Inputs
- `text` - Text input with validation
- `email` - Email input with built-in validation
- `password` - Password input with show/hide toggle
- `number` - Number input with min/max/step
- `textarea` - Multi-line text with character limits
- `search` - Search input with debounced onChange

#### Selection Controls
- `select` - Single/multi-select dropdown
- `autocomplete` - Searchable select with freeSolo option
- `hierarchical-select` - Cascading selects (Country → State → City)
- `radio` - Radio button groups with horizontal/vertical layout
- `checkbox` - Single checkbox or checkbox groups
- `switch` - Toggle switch control

#### Date/Time Controls
- `date` - Date picker with min/max constraints
- `time` - Time picker (12/24 hour format)
- `datetime` - Combined date/time picker
- `date-range` - Start/end date selection

#### Advanced Controls
- `file` - File upload with drag/drop, type/size validation
- `rating` - Star rating component
- `slider` - Range slider with marks and labels
- `color` - Color picker with presets
- `rich-text` - WYSIWYG editor with configurable toolbar

#### Layout & Grouping
- `group` - Field grouping with collapsible sections
- `repeater` - Dynamic array fields (add/remove items)
- `conditional` - Fields that show/hide based on other field values
- `divider` - Visual separator between sections

### Configuration Schema

```typescript
interface FormConfig {
  // Layout
  columns: number;                    // Grid columns (1-12)
  spacing: number;                   // Grid spacing
  variant: 'outlined' | 'filled' | 'standard';
  size: 'small' | 'medium';
  
  // Form-level settings
  validateOnChange: boolean;
  validateOnBlur: boolean;
  resetOnSubmit: boolean;
  
  // Fields array
  fields: FormField[];
  
  // Actions
  actions?: FormAction[];
  
  // Events
  onSubmit: (data: any) => void | Promise<void>;
  onChange?: (data: any, field: string) => void;
  onValidationError?: (errors: any) => void;
}

interface FormField {
  // Core properties
  type: FormFieldType;
  name: string;
  label: string;
  
  // Layout
  span?: number;                     // Column span (1-12)
  order?: number;                    // Field order
  
  // State
  required?: boolean;
  disabled?: boolean;
  hidden?: boolean;
  readonly?: boolean;
  
  // Validation
  validation?: ValidationRule[];
  
  // UI
  placeholder?: string;
  helperText?: string;
  startAdornment?: ReactNode;
  endAdornment?: ReactNode;
  
  // Type-specific options
  options?: SelectOption[];          // For select/radio/checkbox
  multiple?: boolean;                // For select/file
  accept?: string;                   // For file
  min?: number;                      // For number/date
  max?: number;                      // For number/date
  step?: number;                     // For number/slider
  rows?: number;                     // For textarea
  
  // Conditional rendering
  condition?: {
    field: string;
    operator: 'equals' | 'not-equals' | 'contains' | 'greater-than' | 'less-than';
    value: any;
  };
  
  // Events
  onChange?: (value: any) => void;
  onBlur?: () => void;
  onFocus?: () => void;
}
```

### Advanced Features

#### Hierarchical Selects
```typescript
{
  type: 'hierarchical-select',
  name: 'location',
  levels: [
    { 
      name: 'country', 
      label: 'Country', 
      options: [...],
      loadOptions?: (query: string) => Promise<Option[]>
    },
    { 
      name: 'state', 
      label: 'State', 
      dependsOn: 'country',
      loadOptions: (parentValue: string) => Promise<Option[]>
    }
  ]
}
```

#### Repeater Fields
```typescript
{
  type: 'repeater',
  name: 'contacts',
  label: 'Emergency Contacts',
  addLabel: 'Add Contact',
  removeLabel: 'Remove',
  minItems: 1,
  maxItems: 5,
  fields: [
    { type: 'text', name: 'name', label: 'Name', required: true },
    { type: 'select', name: 'relationship', label: 'Relationship', options: [...] },
    { type: 'text', name: 'phone', label: 'Phone' }
  ]
}
```

#### Dynamic Validation
```typescript
const createValidationSchema = (fields: FormField[]) => {
  const schemaObject: Record<string, ZodType> = {};
  
  fields.forEach(field => {
    let validator = getBaseValidator(field.type);
    
    if (field.required) validator = validator.min(1, 'Required');
    if (field.validation) {
      field.validation.forEach(rule => {
        validator = applyValidationRule(validator, rule);
      });
    }
    
    schemaObject[field.name] = validator;
  });
  
  return z.object(schemaObject);
};
```

### Component Architecture

```
DynamicForm/
├── index.ts                    # Main export
├── DynamicForm.tsx            # Main form component
├── hooks/
│   ├── useFormConfig.ts       # Form configuration hook
│   ├── useFieldValidation.ts  # Dynamic validation
│   └── useConditionalFields.ts # Conditional field logic
├── fields/
│   ├── TextField.tsx          # Text input field
│   ├── SelectField.tsx        # Select field
│   ├── HierarchicalSelect.tsx # Cascading select
│   ├── RepeaterField.tsx      # Array field
│   └── index.ts               # Field registry
├── utils/
│   ├── validation.ts          # Validation utilities
│   ├── layout.ts              # Layout calculations
│   └── fieldRegistry.ts       # Field type mapping
└── types/
    ├── form.ts                # Form interfaces
    ├── fields.ts              # Field interfaces
    └── validation.ts          # Validation interfaces
```

### Storybook Stories

Create comprehensive stories covering:
- **Basic Form**: Simple text inputs and validation
- **Advanced Controls**: All field types demonstration
- **Hierarchical Selects**: Country/State/City example
- **Repeater Fields**: Dynamic contact list
- **Conditional Fields**: Show/hide based on selections
- **Validation Showcase**: All validation types
- **Layout Examples**: 1, 2, 3, 4 column layouts
- **Real-world Examples**: User registration, settings, survey forms

### Performance Considerations
- **Lazy loading**: Load field components on demand
- **Memoization**: Prevent unnecessary re-renders
- **Debounced validation**: Avoid excessive validation calls
- **Virtual scrolling**: For large forms with many fields
- **Code splitting**: Separate bundles for different field types

### Accessibility Requirements
- **Keyboard navigation**: Full keyboard support
- **Screen reader support**: Proper ARIA labels and descriptions
- **Focus management**: Logical tab order
- **Error announcements**: Screen reader error notifications
- **High contrast**: Support for high contrast themes

### Testing Strategy
- **Unit tests**: Each field component and utility
- **Integration tests**: Form submission and validation flows
- **Visual regression**: Storybook visual testing
- **Accessibility tests**: axe-core integration
- **Performance tests**: Large form rendering benchmarks

## Implementation Phases

### Phase 1: Core Infrastructure
- Basic form component with text/email/number fields
- React Hook Form integration
- Zod validation setup
- MUI Grid layout system

### Phase 2: Advanced Fields
- Select, radio, checkbox controls
- Date/time pickers
- File upload component
- Rich text editor

### Phase 3: Complex Features
- Hierarchical selects
- Repeater fields
- Conditional field logic
- Advanced validation rules

### Phase 4: Polish & Performance
- Accessibility improvements
- Performance optimizations
- Comprehensive testing
- Documentation and examples

## Success Criteria
- ✅ All field types implemented and tested
- ✅ Full TypeScript support with type inference
- ✅ Responsive layouts work on all screen sizes
- ✅ WCAG 2.1 AA accessibility compliance
- ✅ Performance benchmarks met (< 100ms render time)
- ✅ Comprehensive Storybook documentation
- ✅ 90%+ test coverage
- ✅ Successfully used in 3+ real-world forms across applications
