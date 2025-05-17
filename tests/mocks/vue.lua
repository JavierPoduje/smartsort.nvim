local Region = require("region")

local simple = {
    content = {
        '<template>',
        '  <h1 :class="$style.title">{{ title }}</h1>',
        '</template>',
        '',
        '<script setup lang="ts">',
        'import { ref } from "vue";',
        '',
        'const bbb = ref("another");',
        'const aaa =',
        '  ref("Hello World");',
        '</script>',
        '',
        '<style lang="scss" module>',
        '.title {',
        '  color: blue;',
        '  font-size: 20px;',
        '}',
        '</style>',
    },
    region = Region.new(8, 1, 10, 21),
}

return {
    simple = simple,
}
