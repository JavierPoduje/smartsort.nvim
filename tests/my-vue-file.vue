<template>
  <h1 :class="$style.title">{{ title }}</h1>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const another = ref('another');
const title =
  ref('Hello World');
</script>

<style lang="scss" module>
.title {
  color: blue;
  font-size: 20px;
}
</style>
