PORTNAME=	codimd
DISTVERSION=	g20250424	# no recent release
CATEGORIES=	www
MASTER_SITES=	LOCAL/mikael/codimd/:npm
DISTFILES=	codimd-${DISTVERSION}-npm-cache.tar.gz:npm

MAINTAINER=	ports@FreeBSD.org
COMMENT=	Realtime collaborative markdown notes on all platforms
WWW=		https://hackmd.io/c/codimd-documentation

LICENSE=	AGPLv3
LICENSE_FILE=	${WRKSRC}/LICENSE

BUILD_DEPENDS=	npm:www/npm${NODEJS_SUFFIX}

USES=		nodejs:${NODEJS_VERSION}

USE_GITHUB=	yes
GH_ACCOUNT=	hackmdio
GH_TAGNAME=	6a861a8b

USE_RC_SUBR=	codimd

MAKE_ENV+=	NODE_OPTIONS=--openssl-legacy-provider

do-build:
	${ECHO_CMD} offline=true >> ${WRKSRC}/.npmrc
	cd ${WRKSRC} && \
		${SETENV} ${MAKE_ENV} npm install --ignore-script
	cd ${WRKSRC} && \
		${SETENV} ${MAKE_ENV} npm run build

do-install:
	${MKDIR} ${STAGEDIR}${WWWDIR}

	${RM} -r ${WRKSRC}/bin/heroku \
		${WRKSRC}/bin/heroku_start.sh \
		${WRKSRC}/bin/setup \
		${WRKSRC}/.devcontainer \
		${WRKSRC}/.git* \
		${WRKSRC}/.babelrc \
		${WRKSRC}/.buildpacks \
		${WRKSRC}/.dockerignore \
		${WRKSRC}/.editorconfig \
		${WRKSRC}/.gitignore \
		${WRKSRC}/.mailmap \
		${WRKSRC}/.npmrc \
		${WRKSRC}/.nvmrc \
		${WRKSRC}/node_modules/.cache

	(cd ${WRKSRC} && \
		${COPYTREE_SHARE} . ${STAGEDIR}${WWWDIR})
	${MV} ${WRKSRC}/config.json.example ${STAGEDIR}${WWWDIR}/config.json.sample
	${CP} ${STAGEDIR}${WWWDIR}/config.json.sample ${STAGEDIR}${WWWDIR}/config.json
	${MV} ${WRKSRC}/.sequelizerc.example ${STAGEDIR}${WWWDIR}/.sequelizerc.sample
	${CP} ${STAGEDIR}${WWWDIR}/.sequelizerc.sample ${STAGEDIR}${WWWDIR}/.sequelizerc

	${CHMOD} +x ${STAGEDIR}${WWWDIR}/bin/manage_users
	${CHMOD} +x ${STAGEDIR}${WWWDIR}/node_modules/sequelize-cli/lib/sequelize
	${CHMOD} +x ${STAGEDIR}${WWWDIR}/node_modules/webpack/bin/webpack.js

post-install:
	${FIND} -s ${STAGEDIR}${WWWDIR} -not -type d | ${SORT} | \
		${SED} -e 's#^${STAGEDIR}${PREFIX}/##' > ${TMPPLIST}
	${REINPLACE_CMD} -e 's|^.*\.sample$$|@sample &|' ${TMPPLIST}

create-caches-tarball:
	# do some cleanup first
	${RM} -r ${WRKDIR}/.npm/_logs ${WRKDIR}/.npm/_update-notifier-last-checked

	cd ${WRKDIR} && \
		${TAR} czf codimd-${DISTVERSION}-npm-cache.tar.gz .npm

.include <bsd.port.mk>
