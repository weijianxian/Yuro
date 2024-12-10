# ASMR One App Development Guidelines

[中文版本](guidelines_zh.md)

## Important Notice

These guidelines are living documents that will evolve with the project. Any changes in practice must be reflected in these guidelines, especially the architecture section which must stay consistent with the actual project structure.

## 1. Architecture Design Guidelines

### 1.1 Decoupling Principles
- Follow SOLID principles strictly
- Use dependency injection
- Implement BLoC pattern
- Define interfaces for inter-module communication

### 1.2 Modularization Principles
- Divide modules by functionality
- Follow single responsibility principle
- Clear interface communication
- Share common components

### 1.3 Code Organization
<pre>
lib/
├── core/                 # Core functionality
│   ├── di/              # Dependency injection
│   ├── theme/           # Theme configuration
│   └── utils/           # Utilities
├── data/                # Data layer
│   ├── models/          # Data models
│   ├── repositories/    # Data repositories
│   └── services/        # Service implementations
├── domain/              # Domain layer
│   ├── entities/        # Business entities
│   └── repositories/    # Repository interfaces
├── presentation/        # Presentation layer
│   ├── blocs/          # State management
│   ├── screens/        # Pages
│   └── widgets/        # Components
└── common/             # Common functionality
    ├── constants/      # Constants definitions
    └── extensions/     # Extensions
</pre>

### 1.4 String Management
- All text strings must be centrally defined in `lib/common/constants/strings.dart`
- No hardcoded strings allowed in the code
- String constants should be grouped by feature modules
- Prepared for future internationalization
- String names should clearly express their purpose

Example:
```dart
class Strings {
  // App
  static const String appName = 'asmr.one';
  
  // Common
  static const String loading = 'Loading...';
  
  // Feature specific
  static const String search = 'Search';
}
```

## 2. UI/UX Design Guidelines

### 2.1 Interface Design
- Follow Material Design 3
- Consistent color theme and typography
- Maintain visual hierarchy
- Pixel-perfect alignment

### 2.2 Animation Effects
- Use Flutter's built-in animation system
- Animation duration: 200-300ms
- Use curve animations (Curves.easeInOut)
- Smooth page transitions
- Meaningful micro-interactions

### 2.3 Performance Optimization
- Use const constructors
- Proper use of StatelessWidget
- Avoid complex calculations in build
- Use ListView.builder for long lists
- Image compression and caching

## 3. Code Quality Guidelines

### 3.1 Code Style
- Follow Dart style guide
- Use dartfmt
- Type safety
- Proper documentation

### 3.2 Testing Standards
- Unit test coverage > 80%
- Widget testing
- Integration testing
- Dependency isolation

## 4. Version Control Guidelines

### 4.1 Git Standards
- Feature Branch workflow
- Angular commit convention
- Regular code reviews
- Stable main branch

### 4.2 Release Standards
- Semantic versioning
- Clear changelog
- Complete testing before release
- Documentation updates

## 5. Project Management Guidelines

### 5.1 Documentation Management
- API documentation
- Clear README
- Design decisions
- User and developer guides

### 5.2 Issue Tracking
- Track bugs and features
- Proper labeling
- Task traceability
- Regular status updates 