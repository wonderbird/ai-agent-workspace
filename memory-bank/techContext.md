# Technical Context: AI Agent Rule Reliability

## Technology Stack

### Current Technologies
- **Cursor IDE**: Primary development environment with built-in rule enforcement
- **Git**: Version control with pre-commit hooks capability
- **Markdown**: Documentation format for rules and memory bank
- **Bash/Shell**: Scripting for automation and validation

### Chosen Technologies
- **Cursor IDE Rules System**: Built-in "always apply" rule enforcement
- **VS Code Extensions**: Compatibility layer for familiar development experience
- **Git Integration**: Native git support within Cursor IDE
- **Markdown Rules**: Portable rule content in standard format

## Development Setup

### Current Setup
- **Cursor IDE**: Primary development environment
- **Cursor Rules**: Centralized rule management with "always apply" enforcement
- **Git**: Version control integrated into the IDE
- **Markdown**: Documentation format for memory bank
- **Individual Developer Workflow**: Optimized for solo work

## Technical Constraints

### Individual Developer Constraints
- **No Team Infrastructure**: Solutions must work without shared systems
- **Minimal Dependencies**: Avoid complex external services
- **Personal Customization**: Allow individual preferences
- **Self-contained**: Complete solution in workspace

### Technical Limitations
- **Context Window Limits**: AI models have fixed context windows
- **Session Memory**: No persistent memory across sessions, reliant on Cursor's implementation
- **Rule Complexity**: Multiple rules can overwhelm AI processing
- **Validation Overhead**: Automated checks may slow workflow

## Dependencies

### Internal Dependencies
- Memory bank file hierarchy
- Git workflow integration
- Cursor IDE compatibility

### External Dependencies
- Cursor IDE (commercial license)
- VS Code extensions (for compatibility)
- Git (for version control)
- Markdown (for rule content)

## Tool Usage Patterns

### Current Workflow
- **Prompt Library**: A curated set of prompts is used to guide the AI agent through analysis, implementation, and review cycles.
- **Rule Re-enforcement**: Prompts explicitly instruct the agent to read and apply rules at the start of each major task.
- **Visual Feedback**: An emoji-based system in agent output is used to visually confirm which rules have been applied.
- **Baseline Rule Loading**: Cursor's `always_apply` feature provides an initial set of rules at the beginning of a session.

## Performance Considerations

### Resource Usage
- **Memory**: Efficient caching for rule content
- **CPU**: Lightweight context analysis
- **Storage**: Compressed rule and context data
- **Network**: Minimal external API calls

### Optimization Strategies
- Background processing for non-critical operations
- Incremental validation for changed content only
- Caching validation results
- Batch processing for multiple operations

## Security Considerations

### Data Privacy
- Local storage for personal data
- No external data transmission
- Encrypted storage for sensitive information
- User control over data retention

### Access Control
- Individual developer permissions
- No shared access requirements
- Personal customization settings
- Secure rule definition storage
