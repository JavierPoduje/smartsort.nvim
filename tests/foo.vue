<template>
  <h1 :class="$style.h1style">some h1 element</h1>
  <div>{{ computedProp }} {{ someRef }}</div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const props = defineProps<{
  someProp: string;
}>();

const someRef = ref(0);

const computedProp = computed(() => `hi! ${props.someProp}`);
</script>

<style lang="scss" module>
.h1style {
  border: 1px solid red;
}
</style>
