#!/bin/bash

IP_DROPP=165.22.42.160

## start
echo -n "введите имя хоста <- "
read get_host_name &&


## GLOBAL VARS ================================================================
export HOST_NAME=${get_host_name} &&
export HOST_PREFIX="$(date +%s | sha256sum | base64 | head -c 7)"


########################################################## vestacp
## config vestacp
export VESTACP_USER='admin'
export VESTACP_PASS="$(date +%s | sha256sum | base64 | head -c 22)"
export VESTACP_HTML_PATH="/home/admin/web/$HOST_NAME/public_html"
export VESTACP_SITES_PATH='/home/admin/web/'
export VESTACP_CLI='/usr/local/vesta/bin'
export VESTACP_ROOT='/usr/local/vesta/'
export VESTA=${VESTACP_ROOT}

## callback users info
export GET_WP_TAR='https://www.dropbox.com/s/oo4x4ltdi5dj79q/wp.tar'
export GET_BD='https://www.dropbox.com/s/o1de8utq26acljf/back.sql'

export wp_and_db_user="${VESTACP_USER}_${HOST_PREFIX}"
export wp_and_db_pass=${VESTACP_PASS}


echo "создатся domain"
bash ${VESTACP_CLI}/v-add-web-domain ${VESTACP_USER} ${HOST_NAME}
echo "domain создан" &&
echo "создатся database"
bash ${VESTACP_CLI}/v-add-database ${VESTACP_USER} ${HOST_PREFIX} ${HOST_PREFIX} ${VESTACP_PASS}
echo "database создан"
echo "включаю ssl"
bash ${VESTACP_CLI}/v-add-letsencrypt-domain ${VESTACP_USER} ${HOST_NAME}
echo "ssl включен"
sleep 5 &&




########################################################## wordpress
echo "----------------"
echo "clean $VESTACP_HTML_PATH"
echo "----------------"
echo "загружается wordpress"


rm ${VESTACP_HTML_PATH}/* &&
sleep 2 && echo 'качаю sql'
wget ${GET_BD}  -P ${VESTACP_HTML_PATH}
sleep 2 && echo 'скачал sql'
curl -L ${GET_WP_TAR} | tar -xvf - -C ${VESTACP_HTML_PATH}
curl -L ${GET_BD} | tar -xvf - -C ${VESTACP_HTML_PATH}
mkdir ${VESTACP_HTML_PATH}/pages


## wp-config vars
string_table_prefix='$table_prefix  ='
string_prefix='wp_'
# gen wp config file
WP_CONF=$(cat <<EOF
<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', '${wp_and_db_user}');

/** MySQL database username */
define('DB_USER', '${wp_and_db_user}');

/** MySQL database password */
define('DB_PASSWORD', '${wp_and_db_pass}');

/** MySQL hostname */
define('DB_HOST', 'localhost');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8mb4');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         '');
define('SECURE_AUTH_KEY',  '');
define('LOGGED_IN_KEY',    '');
define('NONCE_KEY',        '');
define('AUTH_SALT',        '');
define('SECURE_AUTH_SALT', '');
define('LOGGED_IN_SALT',   '');
define('NONCE_SALT',       '');

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
${string_table_prefix}'${string_prefix}';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
define('WP_DEBUG', false);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
EOF
)

PRIVACY_POLICY=$(cat <<EOF
Privacy Policy
Herbonce (\"us\", \"we\", or \"our\") operates the ${HOST_NAME} website (the \"Service\").
This page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Service and the choices you have associated with that data.
We use your data to provide and improve the Service. By using the Service, you agree to the collection and use of information in accordance with this policy. Unless otherwise defined in this Privacy Policy, terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, accessible from ${HOST_NAME}
Information Collection And Use
We collect several different types of information for various purposes to provide and improve our Service to you.
Types of Data Collected
Personal Data
While using our Service, we may ask you to provide us with certain personally identifiable information that can be used to contact or identify you (\"Personal Data\"). Personally identifiable information may include, but is not limited to:
Email address
Cookies and Usage Data
Usage Data
We may also collect information how the Service is accessed and used (\"Usage Data\"). This Usage Data may include information such as your computer's Internet Protocol address (e.g. IP address), browser type, browser version, the pages of our Service that you visit, the time and date of your visit, the time spent on those pages, unique device identifiers and other diagnostic data.
Tracking & Cookies Data
We use cookies and similar tracking technologies to track the activity on our Service and hold certain information.
Cookies are files with small amount of data which may include an anonymous unique identifier. Cookies are sent to your browser from a website and stored on your device. Tracking technologies also used are beacons, tags, and scripts to collect and track information and to improve and analyze our Service.
You can instruct your browser to refuse all cookies or to indicate when a cookie is being sent. However, if you do not accept cookies, you may not be able to use some portions of our Service.
Examples of Cookies we use:
Session Cookies. We use Session Cookies to operate our Service.
Preference Cookies. We use Preference Cookies to remember your preferences and various settings.
Security Cookies. We use Security Cookies for security purposes.
Use of Data
Herbonce uses the collected data for various purposes:
To provide and maintain the Service
To notify you about changes to our Service
To allow you to participate in interactive features of our Service when you choose to do so
To provide customer care and support
To provide analysis or valuable information so that we can improve the Service
To monitor the usage of the Service
To detect, prevent and address technical issues
Transfer Of Data
Your information, including Personal Data, may be transferred to — and maintained on — computers located outside of your state, province, country or other governmental jurisdiction where the data protection laws may differ than those from your jurisdiction.
If you are located outside United Arab Emirates and choose to provide information to us, please note that we transfer the data, including Personal Data, to United Arab Emirates and process it there.
Your consent to this Privacy Policy followed by your submission of such information represents your agreement to that transfer.
Herbonce will take all steps reasonably necessary to ensure that your data is treated securely and in accordance with this Privacy Policy and no transfer of your Personal Data will take place to an organization or a country unless there are adequate controls in place including the security of your data and other personal information.
Disclosure Of Data
Legal Requirements
Herbonce may disclose your Personal Data in the good faith belief that such action is necessary to:
To comply with a legal obligation
To protect and defend the rights or property of Herbonce
To prevent or investigate possible wrongdoing in connection with the Service
To protect the personal safety of users of the Service or the public
To protect against legal liability
Security Of Data
The security of your data is important to us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security.
Service Providers
We may employ third party companies and individuals to facilitate our Service (\"Service Providers\"), to provide the Service on our behalf, to perform Service-related services or to assist us in analyzing how our Service is used.
These third parties have access to your Personal Data only to perform these tasks on our behalf and are obligated not to disclose or use it for any other purpose.
Links To Other Sites
Our Service may contain links to other sites that are not operated by us. If you click on a third party link, you will be directed to that third party's site. We strongly advise you to review the Privacy Policy of every site you visit.
We have no control over and assume no responsibility for the content, privacy policies or practices of any third party sites or services.
Children's Privacy
Our Service does not address anyone under the age of 18 (\"Children\").
We do not knowingly collect personally identifiable information from anyone under the age of 18. If you are a parent or guardian and you are aware that your Children has provided us with Personal Data, please contact us. If we become aware that we have collected Personal Data from children without verification of parental consent, we take steps to remove that information from our servers.
Changes To This Privacy Policy
We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.
We will let you know via email and/or a prominent notice on our Service, prior to the change becoming effective and update the \"effective date\" at the top of this Privacy Policy.
You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.
Contact Us
If you have any questions about this Privacy Policy, please contact us:
By email: contact@${HOST_NAME}
EOF
)


echo "${WP_CONF}" > ${VESTACP_HTML_PATH}/wp-config.php
chmod -R 777 ${VESTACP_HTML_PATH}
#ssh ${connect} "chown -R www-data $VESTACP_HTML_PATH"


### mysql request
mysql -u${wp_and_db_user} -p${wp_and_db_pass} ${wp_and_db_user}  < ${VESTACP_HTML_PATH}/back.sql
mysql -u${wp_and_db_user} -p${wp_and_db_pass} << EOF
use ${wp_and_db_user}

UPDATE wp_users SET
ID = 1,
user_login = '${wp_and_db_user}',
user_pass = md5('${wp_and_db_pass}'),
user_nicename = '${wp_and_db_user}',
user_email = '${wp_and_db_user}@test.com',
user_url = '',
user_registered = '2019-05-19 11:28:16',
user_activation_key = '',
user_status = '0',
display_name = '${wp_and_db_user}'
WHERE ID = '1';

UPDATE wp_options SET
option_id = 186,
option_name = 'ftp_credentials',
option_value = 'a:3:{s:8:\"hostname\";s:14:\"${IP_DROPP}\";s:8:\"username\";s:9:\"${wp_and_db_user}\";s:15:\"connection_type\";s:3:\"ftp\";}',
autoload = 'yes'
WHERE option_id = 186;

UPDATE wp_usermeta SET
umeta_id = 1,
user_id = 1,
meta_key = '${wp_and_db_user}',
meta_value = '${wp_and_db_user}'
WHERE umeta_id = 1;

UPDATE wp_options SET
option_id = 1,
option_name = 'siteurl',
option_value = 'https://${HOST_NAME}',
autoload = 'yes'
WHERE option_id = '1';

UPDATE wp_options SET
option_id = 2,
option_name = 'home',
option_value = 'https://${HOST_NAME}',
autoload = 'yes'
WHERE option_id = 2;



UPDATE wp_posts SET post_content = '"'"${PRIVACY_POLICY}"'"' WHERE wp_posts.ID = 3;

EOF


rm ${VESTACP_HTML_PATH}/back.sql

echo ""
echo "---------------------------------------------------"
tput setaf 5; echo "******** сайт ${HOST_NAME} готов !!!!!!!!!!"
echo "---------------------------------------------------"
tput setaf 1; echo ""
tput setaf 1; echo "скопируйте ссылку"
tput setaf 1; echo "_____________________"
tput setaf 1; echo ""
tput setaf 1; echo "${HOST_NAME}/wp-admin"
tput setaf 1; echo ""
tput setaf 1; echo "_____________________"
tput setaf 3; echo "user: ${wp_and_db_user}"
tput setaf 1; echo "-----------------------"
tput setaf 2; echo "pass: ${wp_and_db_pass}"
tput setaf 1; echo ""
tput setaf 1; echo ""


#sleep 2 &&

#x-www-browser ${HOST_NAME}
## exit
