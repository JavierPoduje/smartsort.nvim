<template>
  <h1 :class="$style.title">{{ title }}</h1>

  <my-component
    :title="title"
    :bbb="bbb"
    :aaa="aaa" />
</template>

<script setup lang="ts">
import { one, two, three, four } from './my-module';
import { ref } from 'vue';

const bbb = ref('another');
const aaa =
  ref('Hello World')
</script>

<style lang="scss" module>
.title {
  color: blue;
  font-size: 20px;
}
</style>
