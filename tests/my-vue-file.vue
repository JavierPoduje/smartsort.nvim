<template>
  <h1 :class="$style.title">{{ title }}</h1>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const zzzz = ref('another');
const cccc =
  ref('Hello World');

const aaaa = {
  a: 1,
  b: 2,
  c: 3,
}
</script>

<style lang="scss" module>
.title {
  color: blue;
  font-size: 20px;
}
</style>
