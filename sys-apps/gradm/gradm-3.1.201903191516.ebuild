# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic toolchain-funcs udev

MY_PV="$(ver_rs 2 -)"

DESCRIPTION="Administrative interface for the grsecurity Role Based Access Control system"
HOMEPAGE="https://www.grsecurity.net/"
SRC_URI="https://dev.gentoo.org/~slashbeast/distfiles/gradm/${PN}-${MY_PV}.tar.gz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~hppa ~mips ~ppc ~ppc64 ~sparc x86"
IUSE="pam"

RDEPEND=""
DEPEND="
	app-alternatives/yacc
	app-alternatives/lex
	pam? ( sys-libs/pam )"

S=${WORKDIR}/${PN}

PATCHES=(
	"${FILESDIR}"/respect-gentoo-env-r3.patch
)

src_prepare() {
	default
	sed -i -e "s:/lib/udev:$(get_udevdir):" Makefile || die
}

src_compile() {
	local target
	use pam || target="nopam"

	# bug #863569
	filter-lto

	emake ${target} CC="$(tc-getCC)" OPT_FLAGS="${CFLAGS}"
}

src_install() {
	emake DESTDIR="${D}" install
	fperms 711 /sbin/gradm
}

pkg_postinst() {
	ewarn
	ewarn "Be sure to set a password with 'gradm -P' before enabling learning mode."
	ewarn
}
