## Languages
- [css](#css)
- [go](#go)
- [javascript](#javascript)
- [lua](#lua)
- [python](#python)
- [scss](#scss)
- [typescript](#typescript)
- [vue](#vue)

## css<a name="css"></a>
### declaration
- query:
    ```schema
    (declaration (property_name) @identifier) @block
    ```
- example:
    ```css
    /*
     * ===== Before sorting =====
     */
    .my-class {
      color: red;
      font-size: 16px;
      border:
        1px
        solid
        black;
    }

    /*
     * ===== After sorting =====
     */
    .my-class {
      border:
        1px
        solid
        black;
      color: red;
      font-size: 16px;
    }
    ```

### rule_set
- query:
    ```schema
    (rule_set (selectors) @identifier) @block
    ```
- example:
    ```css
    /*
     * ===== Before sorting =====
     */
    .bbb {
      background-color: blue;
    }

    .aaa {
      background-color: red;
    }

    /*
     * ===== After sorting =====
     */
    .aaa {
      background-color: red;
    }

    .bbb {
      background-color: blue;
    }
    ```


## go<a name="go"></a>
### function_declaration
- query:
    ```schema
    (function_declaration (identifier) @identifier) @block
    ```
- example:
    ```go
    /*
     * ===== Before sorting =====
     */
    func processData() {
        // implementation
    }

    func calculateSum() {
        // implementation
    }

    func validateInput() {
        // implementation
    }

    /*
     * ===== After sorting =====
     */
    func calculateSum() {
        // implementation
    }

    func processData() {
        // implementation
    }

    func validateInput() {
        // implementation
    }
    ```

### keyed_element
- query:
    ```schema
    (keyed_element (literal_element) @identifier) @block
    ```
- example:
    ```go
    /*
     * ===== Before sorting =====
     */
    data := map[string]int{
        "zebra": 3,
        "apple": 1,
        "banana": 2,
    }

    /*
     * ===== After sorting =====
     */
    data := map[string]int{
        "apple": 1,
        "banana": 2,
        "zebra": 3,
    }
    ```

### method_declaration
- query:
    ```schema
    (method_declaration (field_identifier) @identifier) @block
    ```
- example:
    ```go
    /*
     * ===== Before sorting =====
     */
    func (r *Receiver) ProcessData() {
        // implementation
    }

    func (r *Receiver) CalculateSum() {
        // implementation
    }

    func (r *Receiver) ValidateInput() {
        // implementation
    }

    /*
     * ===== After sorting =====
     */
    func (r *Receiver) CalculateSum() {
        // implementation
    }

    func (r *Receiver) ProcessData() {
        // implementation
    }

    func (r *Receiver) ValidateInput() {
        // implementation
    }
    ```

### short_var_declaration
- query:
    ```schema
    (short_var_declaration (expression_list) @identifier) @block
    ```
- example:
    ```go
    /*
     * ===== Before sorting =====
     */
    banana := "banana"
    date := "date"
    apple := "apple"

    /*
     * ===== After sorting =====
     */
    apple := "apple"
    banana := "banana"
    date := "date"
    ```

### type_case
- query:
    ```schema
    (type_case
        [
            (qualified_type) @identifier
            (type_identifier) @identifier
        ]
    ) @block
    ```
- example:
    ```go
    /*
     * ===== Before sorting =====
     */
    switch v := value.(type) {
    case string:
        fmt.Println("string")
    case int:
        fmt.Println("int")
    case bool:
        fmt.Println("bool")
    }

    /*
     * ===== After sorting =====
     */
    switch v := value.(type) {
    case bool:
        fmt.Println("bool")
    case int:
        fmt.Println("int")
    case string:
        fmt.Println("string")
    }
    ```
## javascript<a name="javascript"></a>
### class_declaration
- query:
    ```schema
    [
        (export_statement (class_declaration (identifier) @identifier))
        (class_declaration (identifier) @identifier)
    ] @block
    ```
- example:
    ```javascript
    /*
     * ===== Before sorting =====
     */
    class Zebra {
        // implementation
    }

    class Apple {
        // implementation
    }

    export class Banana {
        // implementation
    }

    /*
     * ===== After sorting =====
     */
    class Apple {
        // implementation
    }

    export class Banana {
        // implementation
    }

    class Zebra {
        // implementation
    }
    ```

### expression_statement
- query:
    ```schema
    (expression_statement
      (call_expression function: (identifier) @identifier)
    ) @block
    ```
- example:
    ```javascript
    /*
     * ===== Before sorting =====
     */
    processData();
    calculateSum();
    validateInput();

    /*
     * ===== After sorting =====
     */
    calculateSum();
    processData();
    validateInput();
    ```

### function_declaration
- query:
    ```schema
    [
        (export_statement (function_declaration (identifier) @identifier))
        (function_declaration (identifier) @identifier)
    ] @block
    ```
- example:
    ```javascript
    /*
     * ===== Before sorting =====
     */
    function processData() {
        // implementation
    }

    function calculateSum() {
        // implementation
    }

    export function validateInput() {
        // implementation
    }

    /*
     * ===== After sorting =====
     */
    function calculateSum() {
        // implementation
    }

    function processData() {
        // implementation
    }

    export function validateInput() {
        // implementation
    }
    ```

### lexical_declaration
- query:
    ```schema
    [
       (export_statement (lexical_declaration (variable_declarator (identifier) @identifier)))
       (lexical_declaration (variable_declarator (identifier) @identifier))
    ] @block
    ```
- example:
    ```javascript
    /*
     * ===== Before sorting =====
     */
    const zebra = "zebra";
    let apple = "apple";
    export const banana = "banana";

    /*
     * ===== After sorting =====
     */
    let apple = "apple";
    export const banana = "banana";
    const zebra = "zebra";
    ```

### method_definition
- query:
    ```schema
    (method_definition (property_identifier) @identifier) @block
    ```
- example:
    ```javascript
    /*
     * ===== Before sorting =====
     */
    class MyClass {
        processData() {
            // implementation
        }

        calculateSum() {
            // implementation
        }

        validateInput() {
            // implementation
        }
    }

    /*
     * ===== After sorting =====
     */
    class MyClass {
        calculateSum() {
            // implementation
        }

        processData() {
            // implementation
        }

        validateInput() {
            // implementation
        }
    }
    ```

### pair
- query:
    ```schema
    [
      (pair (property_identifier) @identifier)
      ((shorthand_property_identifier) @identifier)
    ] @block
    ```
- example:
    ```javascript
    /*
     * ===== Before sorting =====
     */
    const data = {
        zebra: 3,
        apple: 1,
        banana: 2,
    };

    /*
     * ===== After sorting =====
     */
    const data = {
        apple: 1,
        banana: 2,
        zebra: 3,
    };
    ```

### shorthand_property_identifier
- query:
    ```schema
    [
      (pair (property_identifier) @identifier)
      ((shorthand_property_identifier) @identifier)
    ] @block
    ```
- example:
    ```javascript
    /*
     * ===== Before sorting =====
     */
    const aaa = 'aaa';

    export default {
      bbb: 'bbb',
      aaa,
    }

    /*
     * ===== After sorting =====
     */
    const aaa = 'aaa';

    export default {
      aaa,
      bbb: 'bbb',
    }
    ```

### public_field_definition
- query:
    ```schema
    (public_field_definition (property_identifier) @identifier) @block
    ```
- example:
    ```javascript
    /*
     * ===== Before sorting =====
     */
    class MyClass {
        zebra = "zebra";
        apple = "apple";
        banana = "banana";
    }

    /*
     * ===== After sorting =====
     */
    class MyClass {
        apple = "apple";
        banana = "banana";
        zebra = "zebra";
    }
    ```

### switch_case
- query:
    ```schema
    (switch_case
      value: ([ (binary_expression) (identifier) (number) (string) ] @identifier)
    ) @block
    ```
- example:
    ```javascript
    /*
     * ===== Before sorting =====
     */
    switch (value) {
        case "zebra":
            console.log("zebra");
            break;
        case "apple":
            console.log("apple");
            break;
        case "banana":
            console.log("banana");
            break;
    }

    /*
     * ===== After sorting =====
     */
    switch (value) {
        case "apple":
            console.log("apple");
            break;
        case "banana":
            console.log("banana");
            break;
        case "zebra":
            console.log("zebra");
            break;
    }
    ```
## lua<a name="lua"></a>
### assignment_statement
- query:
    ```schema
    (assignment_statement
      (variable_list
        (dot_index_expression
          field: (identifier) @identifier))
    ) @block
    ```
- example:
    ```lua
    /*
     * ===== Before sorting =====
     */
    module.zebra = "zebra"
    module.apple = "apple"
    module.banana = "banana"

    /*
     * ===== After sorting =====
     */
    module.apple = "apple"
    module.banana = "banana"
    module.zebra = "zebra"
    ```

### field
- query:
    ```schema
    (field (identifier) @identifier) @block
    ```
- example:
    ```lua
    /*
     * ===== Before sorting =====
     */
    local data = {
        zebra = "zebra",
        apple = "apple",
        banana = "banana",
    }

    /*
     * ===== After sorting =====
     */
    local data = {
        apple = "apple",
        banana = "banana",
        zebra = "zebra",
    }
    ```

### function_call
- query:
    ```schema
    (function_call name: (identifier) @identifier) @block
    ```
- example:
    ```lua
    /*
     * ===== Before sorting =====
     */
    processData()
    calculateSum()
    validateInput()

    /*
     * ===== After sorting =====
     */
    calculateSum()
    processData()
    validateInput()
    ```

### function_declaration
- query:
    ```schema
    ([
        (function_declaration (identifier) @identifier)
        (function_declaration
            (method_index_expression
                method: (identifier) @identifier))
    ]) @block
    ```
- example:
    ```lua
    /*
     * ===== Before sorting =====
     */
    function processData()
        -- implementation
    end

    function MyClass:calculateSum()
        -- implementation
    end

    function validateInput()
        -- implementation
    end

    /*
     * ===== After sorting =====
     */
    function MyClass:calculateSum()
        -- implementation
    end

    function processData()
        -- implementation
    end

    function validateInput()
        -- implementation
    end
    ```

### variable_declaration
- query:
    ```schema
    (variable_declaration
        (assignment_statement
            (variable_list (identifier) @identifier)
        )
    ) @block
    ```
- example:
    ```lua
    /*
     * ===== Before sorting =====
     */
    local zebra = "zebra"
    local apple = "apple"
    local banana = "banana"

    /*
     * ===== After sorting =====
     */
    local apple = "apple"
    local banana = "banana"
    local zebra = "zebra"
    ```
## python<a name="python"></a>
### class_definition
- query:
    ```schema
    (class_definition
        name: (identifier) @identifier
    ) @block
    ```
- example:
    ```python
    #
    # ===== Before sorting =====
    #
    class BClass:
        def __init__(self, b):
            self.b = b

    class AClass:
        def __init__(self, a):
            self.a = a

    #
    # ===== After sorting =====
    #
    class AClass:
        def __init__(self, a):
            self.a = a

    class BClass:
        def __init__(self, b):
            self.b = b
    ```

### expression_statement
- query:
    ```schema
    (expression_statement
        (assignment
            left: (identifier) @identifier
        )
    ) @block
    ```
- example:
    ```python
    #
    # ===== Before sorting =====
    #
    foo = "foo"
    bar = "bar"

    #
    # ===== After sorting =====
    #
    bar = "bar"
    foo = "foo"
    ```

### function_definition
- query:
    ```schema
    (function_definition
        name: (identifier) @identifier
    ) @block
    ```
- example:
    ```python
    #
    # ===== Before sorting =====
    #
    def foo():
        print("foo")

    def bar():
        print("bar")

    #
    # ===== After sorting =====
    #
    def bar():
        print("bar")

    def foo():
        print("foo")
    ```
## scss<a name="scss"></a>
Supports [css](#css) definitions.

## typescript<a name="typescript"></a>
Supports [javascript](#javascript) definitions.

### class_declaration
- query:
    ```schema
    [
        (export_statement (class_declaration (type_identifier) @identifier))
        (class_declaration (type_identifier) @identifier)
    ] @block
    ```
- example:
    ```javascript
    /*
     * ===== Before sorting =====
     */
    class Zebra {
        // implementation
    }

    class Apple {
        // implementation
    }

    export class Banana {
        // implementation
    }

    /*
     * ===== After sorting =====
     */
    class Apple {
        // implementation
    }

    export class Banana {
        // implementation
    }

    class Zebra {
        // implementation
    }
    ```

### interface_declaration
- query:
    ```schema
    [
        (interface_declaration (type_identifier) @identifier)
        (export_statement (interface_declaration (type_identifier) @identifier))
    ] @block
    ```
- example:
    ```typescript
    /*
     * ===== Before sorting =====
     */
    interface ZebraInterface {
        // properties
    }

    interface AppleInterface {
        // properties
    }

    export interface BananaInterface {
        // properties
    }

    /*
     * ===== After sorting =====
     */
    interface AppleInterface {
        // properties
    }

    export interface BananaInterface {
        // properties
    }

    interface ZebraInterface {
        // properties
    }
    ```

### property_signature
- query:
    ```schema
    (property_signature (property_identifier) @identifier) @block
    ```
- example:
    ```typescript
    /*
     * ===== Before sorting =====
     */
    interface MyInterface {
        zebra: string;
        apple: number;
        banana: boolean;
    }

    /*
     * ===== After sorting =====
     */
    interface MyInterface {
        apple: number;
        banana: boolean;
        zebra: string;
    }
    ```

### type_alias_declaration
- query:
    ```schema
    [
        (type_alias_declaration name: (type_identifier) @identifier)
        (export_statement (type_alias_declaration name: (type_identifier) @identifier))
    ] @block
    ```
- example:
    ```typescript
    /*
     * ===== Before sorting =====
     */
    type ZebraType = string;
    type AppleType = number;
    export type BananaType = boolean;

    /*
     * ===== After sorting =====
     */
    type AppleType = number;
    export type BananaType = boolean;
    type ZebraType = string;
    ```

## vue<a name="vue"></a>
### Embedded Languages
In the `<script>` section, supports [javascript](#javascript) and [typescript](#typescript).
In the `<style>` section, supports [css](#css) and [scss](#scss).

### directive_attribute
- query:
    ```schema
    (directive_attribute (directive_value) @identifier) @block
    ```
- example:
    ```vue
    /*
     * ===== Before sorting =====
     */
    <template>
      <my-component
        :bbb="bbb"
        :title="title"
        :aaa="aaa" />
    </template>

    /*
     * ===== After sorting =====
     */
    <template>
      <my-component
        :aaa="aaa"
        :bbb="bbb"
        :title="title" />
    </template>
    ```
