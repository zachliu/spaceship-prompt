#
# Virtual Private Network (VPN)
#
# Show the VPN status if using nmcli to manage the VPN profile "aws"
#

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_VPN_SHOW="${SPACESHIP_VPN_SHOW=true}"
SPACESHIP_VPN_PREFIX="${SPACESHIP_VPN_PREFIX=""}"
SPACESHIP_VPN_SUFFIX="${SPACESHIP_VPN_SUFFIX=""}"
SPACESHIP_VPN_SYMBOL="${SPACESHIP_VPN_SYMBOL="🔒 "}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Shows selected VPN-cli profile.
spaceship_vpn() {
  [[ $SPACESHIP_VPN_SHOW == false ]] && return

  # Check if the nmcli is installed
  spaceship::exists nmcli || return

  local STATUS vpn_status=""

  STATUS=$(command nmcli c show --active 2> /dev/null | rg aws)

  if [[ -n ${STATUS} ]]; then
    vpn_status=$SPACESHIP_VPN_SYMBOL
  fi

  # Show prompt section
  spaceship::section \
    "$SPACESHIP_VPN_PREFIX" \
    "$vpn_status" \
    "$SPACESHIP_VPN_SUFFIX"
}
