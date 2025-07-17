# TOMAT UI System Documentation

## Overview

The TOMAT UI system is a Godot-based application that provides a tactile interface with WebSocket communication capabilities. The system manages button states, provides haptic feedback, and communicates with external clients through WebSocket connections.

## Architecture Overview

```mermaid
graph TB
    subgraph "External Clients"
        A[Client 1] 
        B[Client 2]
        C[Client N]
    end
    
    subgraph "TOMAT UI Application"
        D[WebSocket Server] 
        E[Model Manager]
        F[Button Grid System]
        G[Navigation Buttons]
        H[Globals]
    end
    
    A <--> D
    B <--> D
    C <--> D
    D --> E
    E --> F
    F --> D
    G --> D
    H --> E
    H --> F
```

## Component Details

### 1. WebSocket Communication System

The WebSocket server (`websocket_server.gd`) acts as the central communication hub, managing connections with external clients and facilitating bidirectional data exchange.

**Key Features:**
- Singleton pattern for global access
- Multi-client support with unique client IDs
- Automatic connection management and cleanup
- Signal-based communication with internal components

```mermaid
sequenceDiagram
    participant Client
    participant WSServer as WebSocket Server
    participant ModelMgr as Model Manager
    participant Button
    
    Note over Client,Button: Initial Connection & Setup
    Client->>WSServer: Connect via TCP
    WSServer->>WSServer: Create WebSocketPeer
    WSServer->>WSServer: Assign Client ID
    
    Note over Client,Button: Model State Update
    Client->>WSServer: JSON State Data
    WSServer->>ModelMgr: emit model_data_received
    ModelMgr->>Button: set_state()
    Button->>Button: Update appearance & vibration
    
    Note over Client,Button: Button Input Event
    Button->>WSServer: Button event (BxD* or BxU*)
    WSServer->>Client: Forward button event
```

### 2. Model Manager System

The Model Manager (`model_manager.gd`) serves as the central controller that translates external state data into button behaviors and manages the overall UI state.

**State Management Process:**
The system uses a three-tier state hierarchy: INACTIVE (gray, no feedback), ACTIVE (green, continuous vibration), and PULSATING (red, pulsed vibration). When state data arrives via WebSocket, the Model Manager first resets all buttons to INACTIVE, then applies the new states according to the JSON structure.

```mermaid
flowchart TD
    A[JSON Data Received] --> B[Parse JSON String]
    B --> C{Parse Success?}
    C -->|No| D[Log Error & Return]
    C -->|Yes| E[Reset All Buttons to INACTIVE]
    E --> F[Process Each Row Data]
    F --> G{Row Has 'state' Field?}
    G -->|Yes| H[Set Entire Row State]
    G -->|No| I{Row Has 'buttons' Field?}
    I -->|Yes| J[Set Individual Button States]
    I -->|No| K[Skip Row]
    H --> L[Update Button Appearance]
    J --> L
    K --> L
    L --> M[Continue to Next Row]
```

**JSON Data Structure:**
```json
{
  "rows": [
    {
      "row": 0,
      "state": "ACTIVE"
    },
    {
      "row": 1,
      "buttons": [
        {"id": 0, "state": "PULSATING"},
        {"id": 1, "state": "ACTIVE"}
      ]
    }
  ]
}
```

### 3. Button Behavior System

The button system consists of two main types: standard input buttons (`btn_input.gd`) and row element buttons (`btn_rowElement.gd`). Each serves different purposes but both contribute to the overall tactile experience.

#### Standard Input Buttons

Standard input buttons handle basic press/release detection and communicate these events to connected clients. They track state changes frame-by-frame to ensure precise event timing.

```mermaid
stateDiagram-v2
    [*] --> Released
    Released --> Pressed: is_pressed() && !_was_pressed
    Pressed --> Released: !is_pressed() && _was_pressed
    
    Released: Button Up State
    Pressed: Button Down State
    
    note right of Pressed
        Send "BxD*" message
        Print press event
    end note
    
    note right of Released
        Send "BxU*" message  
        Print release event
    end note
```

#### Row Element Buttons

Row element buttons provide sophisticated tactile feedback based on their assigned state. They handle multi-touch input, vibration patterns, and visual state changes.

**Touch Detection System:**
The touch system tracks multiple simultaneous touches using a dictionary that maps touch indices to their inside/outside status. This allows for complex multi-finger interactions while maintaining accurate vibration feedback.

```mermaid
flowchart TD
    A[Touch Event] --> B{Event Type}
    B -->|ScreenTouch| C{Touch Pressed?}
    B -->|ScreenDrag| D[Update Touch Position]
    
    C -->|Yes| E[Add to active_touches]
    C -->|No| F[Remove from active_touches]
    
    D --> G{Position Changed?}
    G -->|Yes| H[Update inside/outside status]
    G -->|No| I[No Action]
    
    E --> J{First Touch Inside?}
    F --> K{Was Inside?}
    H --> L[Update Vibration State]
    
    J -->|Yes| M[Start Vibration]
    J -->|No| N[No Vibration]
    K -->|Yes| O[Update Vibration State]
    K -->|No| P[No Action]
    
    M --> Q[Continue Processing]
    N --> Q
    O --> Q
    P --> Q
    L --> Q
    I --> Q
```

**Vibration Patterns:**

Each button state produces a distinct vibration pattern to provide clear tactile feedback:

- **ACTIVE State**: Continuous vibration with 50ms pulses every 50ms while touched
- **PULSATING State**: Complex pulsing pattern with configurable on/off durations
- **INACTIVE State**: No vibration

```mermaid
gantt
    title Vibration Patterns by State
    dateFormat X
    axisFormat %L
    
    section ACTIVE
    Continuous Vibration    :0, 400
    
    section PULSATING  
    Pulse On               :0, 200
    Pulse Off              :200, 400
    Pulse On               :400, 600
    Pulse Off              :600, 800
    
    section INACTIVE
    No Vibration           :0, 400
```

### 4. Complete Event Flow

Understanding the complete event flow helps visualize how user interactions translate into system responses and client notifications.

```mermaid
sequenceDiagram
    participant User
    participant InputBtn as Input Button
    participant WSServer as WebSocket Server
    participant Client
    participant ModelMgr as Model Manager
    participant RowBtn as Row Button
    
    Note over User,RowBtn: User Interaction Flow
    User->>InputBtn: Press Button
    InputBtn->>WSServer: Send "BxD*"
    WSServer->>Client: Forward button down
    
    User->>InputBtn: Release Button  
    InputBtn->>WSServer: Send "BxU*"
    WSServer->>Client: Forward button up
    
    Note over User,RowBtn: State Update Flow
    Client->>WSServer: Send JSON State Data
    WSServer->>ModelMgr: emit model_data_received
    ModelMgr->>RowBtn: set_state(new_state)
    RowBtn->>RowBtn: Update appearance
    RowBtn->>RowBtn: Configure vibration pattern
    
    Note over User,RowBtn: Tactile Feedback Flow
    User->>RowBtn: Touch Button
    RowBtn->>RowBtn: Detect touch inside
    RowBtn->>RowBtn: Start vibration based on state
    User->>RowBtn: Move finger
    RowBtn->>RowBtn: Update vibration based on position
    User->>RowBtn: Release touch
    RowBtn->>RowBtn: Stop vibration
```

## State Management Deep Dive

The state management system operates on a hierarchical principle where the Model Manager maintains authoritative control over all button states. This centralized approach ensures consistency and prevents conflicting state changes.

**State Transition Logic:**

When a state change occurs, the system follows a specific sequence: first, all existing vibration patterns are immediately stopped to prevent interference; second, the visual appearance is updated to reflect the new state; finally, the new vibration pattern is configured but not started until actual touch input occurs.

```mermaid
stateDiagram-v2
    [*] --> INACTIVE
    INACTIVE --> ACTIVE: External JSON Command
    INACTIVE --> PULSATING: External JSON Command
    ACTIVE --> INACTIVE: External JSON Command  
    ACTIVE --> PULSATING: External JSON Command
    PULSATING --> INACTIVE: External JSON Command
    PULSATING --> ACTIVE: External JSON Command
    
    INACTIVE: Gray Color<br/>No Vibration
    ACTIVE: Green Color<br/>Continuous Vibration
    PULSATING: Red Color<br/>Pulsed Vibration
```
