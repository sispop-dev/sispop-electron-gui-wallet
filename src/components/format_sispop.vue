<template>
  <span> {{ value }} SISPOP </span>
</template>

<script>
export default {
  name: "FormatSispop",
  props: {
    amount: {
      type: Number,
      required: true
    },
    round: {
      type: Boolean,
      required: false,
      default: false
    },
    rawValue: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  computed: {
    value() {
      let value = this.amount / 1e9;
      if (this.round) value = value.toFixed(3);
      return this.rawValue ? value : value.toLocaleString();
    }
  }
};
</script>

<style></style>
