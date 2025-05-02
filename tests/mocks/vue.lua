local Region = require("region")


local simple = {
    content = {
        '<template>',
        '  <h1>this is a title</h1>',
        '</template>',
        '',
        '<script setup lang="ts">',
        'import Foo from "foo";',
        'import Bar from "bar";',
        '',
        'const props = defineProps<{',
        '  someProp: string;',
        '  anotherProp: boolean;',
        '}>();',
        '',
        'const aComputedVar = computed(() => `computed ${props.someProp}`);',
        '</script>',
    },
    region = Region.new(9, 1, 14, 66),
}

return {
    simple = simple,
}
