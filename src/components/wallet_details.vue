<template>
  <div class="column wallet-info">
    <div class="row justify-between items-center wallet-header">
      <div class="title">{{ info.name }}</div>
      <WalletSettings />
    </div>
    <div class="wallet-content oxen-navy">
      <div class="row justify-center">
        <div class="funds column items-center">
          <div class="balance">
            <q-btn-toggle
              v-model="balancestakeselector"
              text-color="white"
              toggle-text-color="primary"
              flat
              :options="[
                {
                  label: $t('strings.oxenBalance'),
                  value: 'balance'
                },
                {
                  label: $t('strings.stake'),
                  value: 'stake'
                }
              ]"
            />
            <div class="value">
              <span><FormatOxen :amount="info.balance"/></span>
            </div>
          </div>
          <div v-if="balancestakeselector != 'stake'" class="row unlocked">
            <span
              >{{ $t("strings.oxenUnlockedShort") }}:
              <FormatOxen :amount="info.unlocked_balance"
            /></span>
          </div>
          <div v-if="balancestakeselector == 'stake'" class="row unlocked">
            <span v-if="info.accrued_balance > 0"
              >{{ $t("strings.oxenAccumulatedRewards") }}:
              <FormatOxen :amount="info.accrued_balance" />•
              {{ $t("strings.nextPayout") }}:
              <FormatNextPayout
                :payout-block="info.accrued_balance_next_payout"
                :current-block="info.height"
              />
            </span>
            <span v-if="info.accrued_balance == 0">
              No accumulated rewards from staking
            </span>
          </div>
        </div>
      </div>
      <div class="wallet-address row justify-center items-center">
        <div class="address">{{ info.address }}</div>
        <CopyIcon :content="info.address" />
      </div>
    </div>
  </div>
</template>

<script>
import { mapState } from "vuex";
import FormatOxen from "components/format_oxen";
import FormatNextPayout from "components/format_next_payout";
import WalletSettings from "components/menus/wallet_settings";
import CopyIcon from "components/icons/copy_icon";
export default {
  name: "WalletDetails",
  components: {
    FormatOxen,
    FormatNextPayout,
    WalletSettings,
    CopyIcon
  },
  computed: mapState({
    theme: state => state.gateway.app.config.appearance.theme,
    info: state => state.gateway.wallet.info
  }),
  data() {
    return {
      balancestakeselector: "balance"
    };
  }
};
</script>

<style lang="scss">
.wallet-info {
  .wallet-header {
    padding: 0.8rem 1.5rem;
    .title {
      font-weight: bold;
    }
  }

  .wallet-content {
    text-align: center;
    padding: 2em;

    .balance {
      .text {
        font-size: 16px;
      }
      .value {
        font-size: 35px;
      }
    }

    .wallet-address {
      margin-top: 12px;
      .address {
        overflow: hidden;
        text-overflow: ellipsis;
        margin: 4px 0;
      }
      .q-btn {
        margin-left: 8px;
      }
    }

    .unlocked {
      font-size: 14px;
      font-weight: 500;
    }
  }
}
</style>
