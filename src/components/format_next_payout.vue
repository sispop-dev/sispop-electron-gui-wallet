<template>
  <span> {{ value }} </span>
</template>

<script>
export default {
  name: "FormatNextPayout",
  props: {
    payoutBlock: {
      type: Number,
      required: true
    },
    currentBlock: {
      type: Number,
      required: true
    }
  },
  computed: {
    value() {
      console.log(this.payoutBlock);
      console.log(this.currentBlock);
      if (this.payoutBlock == 0) return "";

      let blocks = this.payoutBlock - this.currentBlock;
      console.log(this.currentBlock);

      if (blocks > 720) return (blocks / 720).toFixed(1) + " days";
      else if (blocks > 30) return (blocks / 30).toFixed(1) + " hours";
      else return blocks * 2 + " minutes";
    }
  }
};
</script>

<style></style>
