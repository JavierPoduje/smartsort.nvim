<template>
  <h1 :class="$style.title">{{ title }}</h1>

  <my-component
    :bbb="bbb"
    :title="title"
    :aaa="aaa" />
</template>

<script setup lang="ts">
import { one, two, three, four } from './my-module';
import { ref } from 'vue';

const bbb = ref('another');
const aaa =
  ref('Hello World')
</script>

<style module>
.title {
  color: blue;
  font-size: 20px;
}
</style>
