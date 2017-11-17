ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ��Z �=�r�v�Mr����[�T>�W߱je��y�� �H|I�l_m340b���B�n�nU^ ��wȏ<G^ ��3�������kNծp��ӧ?N�9�O����̀b�;������`��=��0D�"��	��/���E�a�GDN��t>*Ģ� wO��ǲ�	�#ۄ]՚��(�W
]dZ���-a�a,dvUY;�7'����K���#�\�m�3̥�j6pZ��A��jd���)EQ;�i[.I `k���v���hһ�i�m����a��$ϓ��t6�^y |�"�*ЬY�x;�>�o#֠1�t��u	F�_��rp��'0{��)�ڪ��)�t��4ҰRLd����r�$��Åm�L�v(b�	ui.�L��Ss���f��Бb�N;2������{����j�ʼ�א��j�v���0���A�r�(ظ�W[����B�c��lä����F�i
'4�Ej��z�622�a���g�5d�)�p�g�萖cj����QvB!�r]�vGC�;1.��v׳'ŜV(�"�:j�4�T��dS�̡��s��y��|��8^������W`��t'�/.����R~v�͐J���i|M��A�])���P禶t�t�D]<�oK1��s�n�O�v��h����kFGv�0[t_��:t4o�@�62u�������e>�.���]�5�����н�A��X,2K�#0�����E^�=�{�d
|��ߔ�V�����A��lt�#�ǟ:�B��3���1Q����*��BUUU��d,�1�ͧ@��?5�$+&��1!���K��bR~˽�f�3����j�W�\3 V6�d����_#L�"�d8?���m`-�+����0E���m4t($�6��"pg�Ǫ ���Wk���a��w�҂���^��q����R?��GEA\��*�8������:�|q�r���:�EZ��D�,`���f�lA�0�	iF�8ű�i٠��3���1�.ފ0u�tM2�Wm����CoC�=���h�B8��T�+4���6�
���b�c7s���J��i��t��-a�i������3�gx�.K��\V5Ci)M8�ڳ��9�C-����n'[��VU���4�.=`��� �C�� �N�I�b<j��� ��tEE>��P�c8܆45иR�,>(=�n_/'>�3(�K�����^�_ ���H�����˚��?�N�\,�^�W~��y���N�݄6h���^&j]�0]W���P�b��,��<}�|d�#~w�i�N!б@��3F���D�<���]����KBR�kR�`�q}�6��ެ����	���(��2SWq��x��_�0��"i���Tk�%uR�5������Sr@�&1�1���шi���~[̸[n�*��ǰK ��c�hW�}mƐ���a�,2�vu2G��3֣ʃ ؟�A���i����C���c�s�$w�B�A�=raL��6-Dx��g�n�rq��Rx�=����������l�+�2�Ok�)���@;�^�#����%����P_�N��#��gl8��L���M�3<ʚ���� T�Q�z�r�8Q��횗7P�0�Tm/YPaj���[��
S�2����K����h$^��������)�?�{�c������[�V����a\��u:P�M�hc���Qv3&��:�c�� ^4��c�}&�-�~�j����R��=*����&���_<Ů�[�}��[�%�+������l��X.������#���y��jG������&�Q�������^P!�4ͦ�)K`ks<3K�����R�|^����Jy6�ch�x�#੅�`լg7�0Vz���m j��v������?ߤA���?��o��Ԋw�6M޿C���3Y�y��C�;�*2Y���%�JOʒ>Y���C�O2<��ِ��yn�;9-0
;>�دh�y�7�伈�ev�E�����!�b��p����������:���Po8���].�G� �5�����E��H@��д�� \$�a����baa-������ɧ�}O�N�:M� ^��%l��Aok_[�K���P�������1.*��W�ǟ�8K͂E��`����D��9~=���ێ�2���XxB�����%0q�+3�бnZ6@�i�/@�Tu�;m��^��1��Kv{d��.�B~9&b�bro��n���/��D�O�a���c��?J���%�`��o٨H��V�)Ë̔�M��tp+�)�r�{����2a���;��j$H�F��f���tx��B�j��Ş@ݘ�諈F)F��ce��?�8s&��{��N��5�>l��F(�@��*�on��/s)d��'����^�W˯����Us����ㅈذᮥ���N9� ��d�@��?ԛ����� |����x'l�ݻ��ߩ�Q���X���[�_�R��ǲ>���Bd���˿'�s��z��`5)-7���r՚��C���� 97���+�0��Ys?*#�F��N��ف�����k�@:�>b*O7����3�(��}���m�+�������J�i�_���_��|���^��"�O4�wo���!pO��T,7r��i*�ͧ7����̐��g�97k�.'�9�p6&I�"A��{���S}t�PyÅL[��ė�?���4xBv�C��A��[%�u�{f�4���Z�>�����w+�F�4,�}��{��{��{@d򑐱2"�b��ރS^��x�h�KcuM>�1�!����7�6�p��ǽÜ|=�Ś���z�e�]����0G��T��������<�� M]m��E0M��W��E�&�9DW�Bt���F&f,��l���x^��ʡX�Z��v�ۮo�Q]��J\8��k�S�"�@~;�U>a�b$vn���\,��kKm�DVf!Hf���4(`���hx����� _��Վ��!�SJqGu0�L�\pF4@@!��t^�-�<�$��c����^���H��+Hx��Lm���E�����ӗ/�dڥ���V�Z�t�jTc��c���������.��"�D�� D�k�o%���V���e[m4m,�&����ɧ�onSDp��%�n�ߧ-����1&��������
���8}���>6j ��([?ؖ!-�)�L���%z���ҙ� \��B�WÂ~#w�4�5mF�3�L������s[_�&�����c�A�z�-כ#�֝���Y٬��K���)>�����+�'�q��w��c���Ǖ�������Sо\T�9�p����_$^������9g������������ؿ��~����"�B|���
/�a�Z��x<Z��Q�A$�H���j<,*P�G�q�ێ��Hd�?�e��-3IxC���o�NG#�c��l0�1I���G�o2L��-ôU�����lv�Q�����Ɵ�'���|�͈�2��.k�7��`��=n��������W�������o�	~�""Ѧ>/a����v��w���O5�;�q��?̭����'���Sz�:�����#���>z6����Pk8mhi�BAN^������8��-�Sٝ�,9�P�F�>v�,{t��P��>��CHL<@ !g�y@�'��lR*�4����f���dRR���MH�lQ�;��q�y�Jd�ƛ�j�-��K6N���Y�ꂓ1nO��0������h��ǹK�J*&�cL��l�Ռ֮�_;�D�L_H7O)��q��ȼӕv�9��Sa�2S�޸FY���gW�s��٬�IXg��EU�.�RtqreY�7���������ϕ�^�"+��YNH�M�i����D5W�z��i�P�Ƚ�Ǖ+���GZ�L��Bڂ'g]�霖�\���2��W�������'��&Q���G1�^�pR��ID�}��JeҶ�����n��8�=��e��RN�K9�Lz�{��e�D��޿L�L�T��X��z�r��)�'���Ğ~�:9�i�J��K�iX+�j$;��uz��|)��r��b�L���Fo��\N�$�涖�ɉP�@�x���r������Tߖ�I�%-ҪZ�Wh��R6�6ϠKd�w�Y<h���:m,Yxxhr�t4�
�#{x�;9���`R�RN�$���h�������P-�"q^�#'�PS?{Ke#���Tz��n�jd��~�h�_�kFڐ;P��r�Sz��9��AN�'�x�[�W���;�Ny9��"���u0�|`�Uo=��[��^?����1]���(�����g�i�<�E��R���ٵ;@�v��m_Ê����<�	��:�o5�ӓ���/����L.���{�4o�Nd�$:T���l�� �o���ڪF3g��1W�ߠ|�DӺZ:����~A�&V���T4�I�P�;�J�*���W�b;�ϫ���[�~��G��T�����H6O�a8�C	P�B���?H�9�F�\��%3Ý�f�>w�9���$j��:�?/
��?DHH�Z�W s�$fY3�Y�Jb�5��em$fY�Y�Bb�5��e�#fY�Y�:b�5��i�3�4�������O�i�E���*��N�s7}���O�f���������A6�7�ҭ��;�����T�x)���
I���)�SXN��]�4��ţ׍<j�3�a�,�k�Hq�go��t1�4�8�����+[�ۺt��,�w���:z���)����7�&9�ܽ�ہO�߭�`���u,�����ߑ�����' it�&���&r�_f'$ME�f�"��d��(��ԛ���ٛ�{�WW��F߿�x1p����n�ٰX )TWu�F�u�;���P�rUҋZ�Q�^�'K>~ȧ��8��U� � O?�=���ц��|�4���&�R)tK�+W�AiF�������W�}`ꁸ��� {�e�_����O�A{o=�Id�L�'5��N�?6s'��z�>��N.Y�{v�>u<���aUs�B�$�M����}S�D����o8�G�ݨ�Ϋ  9��MU�#��NS&����>h��4�<:��� �h��O*$��/�T��i�x��I����Q��V��<y{2!q <-���͋g�ܤ�O�AEP^ ���2�A�$�3Cw�����g�YbI����"g��;vIj�oM����-m�3m���o�\6�R�3��r��r���W��Bڅ�@Z�\7ܐ�WX�eB�q��7���]�O�t��Dg�]vdċ��Eċ�0� �Ǹ-H@��l�{�n{0�&�y����� 7T6W��c�h��̰?ugG�|�1bW>����C��?��\L~�x�J ^l]k��ñ�c;�]�Ơ>����K A�������!�\5���C�v{���	���;)ƒ܇)���p��q��N���pn�џ\+������:W�nā��l������xw��v������@(D#��e%��$���]��7W��#h��E*1Ls?���^�y_�wK��ə�����ѮcΠ�[����u�Z�%!�.��k7�G�+����~�����r]W �dOg=ׁ&���9���	VLH�o�n�\f�����Tz�̂Ty��<�*)�����t7��h�T�l�w�/��ƽ��!P	�1�z=���3C��E�s�G��v�y+�ԍ���L	k��ܭ���>~�
h�?�9<4�;rjY8��]���@��P$[I��wy
�1PLa�����wwk��YD���������� �W�q���J�c���M����\b�>/|���e�������O�*�7<��F�o��������O�%��E|�"�į������_��!�+�:�]L��'�N�♸��Hĕt*�R�X<���8�US�TL��d����j2�P4��L�V��K��#�#�~������?���g����t�T?O����L"�#���V,�o��oQX��~;�ݷw]����[���]������=�+b���{�/�E���Ӟ}s��^�4t�1x��#��Ε�� �i�F)[T��Y�a9�մ���Z��9�]��c�g���1:;�l�-<�ό��Ț���B�:4?#vgdԼ[TV-�u�Y=)�uL[�i� ���"�bJ��zGb�cIl��vM��	�i/&�Qv)�����8y�+�%�.$�Ƹ4�G�I�������;8��`a�{���8�iS�\h�:t��S�p����N3�;�6��a��R���ց�:*-ّR>D�Q��&mG:�L�#jeWB�����L�Z��Ń�LV�|eޤΝ�Zh�R0cr *}1s8��F��ԋQ��s�F"��G�%8>"�)l�`���%7s�a������3�z���V �q��x�H��Lb����薒��L��u��\�;�a09Ol_p��Zn9=��3�� ^mb���Ձ^n���$����Y�gZN(��V2��f�n0�q��O�T]���0Q%����̱Ռ^qv����R���F%���Jد�6�y}&S���P�;����'�Ȳg+*U�tcF#7^^;�E�1p!���bE ��eD��b�֢�@��v�'�a�=�����?�/N�U-5��ti_�t��KU⶞V�li��m�"+�E�'%F?'bz[H%�-��6C��N�mN���������ӈ�t�d�9&��"��+��I���D�
���C�Ҋ�r���s��)3�y"[���ϦTj�HjI�j�-�ɏ;m-�/�q����Ü����̜3*�!���ѱ�ju[�i�F(�>��~?7�gR#�
*.�F����G~a���;���k��+{/�������@l}���%�{�7+��6��/���S�i�e���{_���m��N����k���^��b��Hd����+���\V,������މ��׉�!W�G_��'���G�"߿��{�{���ײ��
�2�e�`g�U����^V�t�$��{d>�����sLӗ�9z��{N�e,�$�c�E�Fk���9q�9̹�u�^�X�cos��m����oXC!��Җ��z��ص�Y�A����n7�uvE��Y*�*p���?��T-ў)�U��b��)�X��z)&7�՞5)8���`�L��:�K�.LJ�&�q����\&�e<ˠ�s$N��j}g8��X�A̴sN��l�2��,�t��/��i�sȁK��o��6#t�+���Z��p,��~�.����LI��htL�$�$��T��Œr�n��-�G@%D�1�Yu�OE�X$��;���Y)�	�ьN�Bz0�J���k�&�e9P��RTZ��8+��L�ji�AcuA�O���o�����򶂜_1Ǿ�̍*_>U��N��"�YV��e�.+�	�7�Ҝ�3��;q[z�ɝ�:������Pn�z�f"�/!W���L�-����s�r��,iV9�r��V�уa[��&j{�r	�m�U��4F�,W�u�ƌ3z�l�V�T�s^����C����8��̻�rNd��%�36Ww��ڣ��4�z-!h��b���A�=8?�k:��4�:��\�$^�M�Q�fG��LM-t��R�=�Zʄ/5������3�]�/.	��I�L�X�sE]��L�7^:6���a)F�h)WO��Ҫ��t⿼�&*$˵ +�Q}2>��3�ʲee ���đ��+HL��x�d���G����Xp�0!n��b�_)L \��¤��y_��5���Y����Qnr`��f�'j�#�=�S�N�����tfޭ7��W҄�mv*�$k��J�h���A!n�2��NdV�)�(�(�/Qv�t�ܑ��l�|�r�J5��S�J�h��<8S�E��C����
K�z3�RZ���ˋ�T��LWbNN��3	�N���<�+LVoE�4���dGdS���u�(�0�R��kg�UΨ�WS����z�G�oB�~H/�j䍰�����e�k��ƅ���{�.�P-{���b�=?��_&~��ckfIˉy3��ef�e��ؽAS_���"��o>y�z��2��M��Gr�E�y�x�^{������0���+��/��ބ��J��ěE`����	FH�'<�������W���8gS<t{�����MorE����Z�d�>�g�>J�/]��XFe�x�����2�-���=�����/~�9������$�ċ���܍�/�F�=��O���i�����}�ްt�Z�CVIG�S�̌��a��Y�)��	���jcw����vME&x���}���zd�g؄)�����?�'}��uz���C���ZUX6BWl�%�8~���	ކ�Y7�\<l���Z=C� �+bw4�pG�A���Cz{���+�n�&A���p\
[��E�!d��a�a`��c,d��Z"�"��TŅz��E�Y����7�T�f�.��]�70&��H�p�#lㅳx�NHR�Ik`���Pf�N!�.���_���%�l�`�/H�kk5l[e��!K85�� ��H��E-O�7�p�p�������lc�[W�>԰Q�\5�	6V�s}j����̆�>j\��!օ"5b�hC&~`������ �ON�����5��?'�x]�+XA%� sA���t̠�h:[�r��
,�N�#�A�qX/z�D�L 醵�>��`�By���zR5�'r:��D�c⚁�A�=�u�qǙƽ�9E��8�{�W��������Ż�~�A�i~	_ ����}�k��>�afc��C��,:=�Tl=���{�kX���M�g�Fb�7?1$X��C]��\�C܋���-�S3�%%�Iw��IB���t������EP�M �P?[�-fN1��Üֻ�5UlٺV��Fڸ�R����	
/�D����@d��"*��le��Pρn��1`I�x�K�c���!��kv�U�ր��uK�5%< /[x��Ż�������'f:0����G��H�RFe1��^�!I[���F
ҳ���4�-��l2��a��(�'x�ؐ(`A�nٰ��,��l��v�NG�+�~6�z����!�µ12����Zvi�Av��O�X��r�'���[�Y ���T얲n�a�,Ϋ��U�͐"n]k_�b�V�&��g�>���7Eal(8]6�����jĖ�Q!ф�m �h�[l=Ag���h���#D'���٩9D�6ǻ�]�yH�}�K ;D�^(+�R��C�S��qc���M����4E���?�0��kN���F~Mt�m�.�T���#��L��[��[芃�3�U�1�C�olj�Ϝ9n���{>� ����"����]Mv��7�������C�][�5���iz;�s2�����{�2������ 
�=W+�s��8�����̡���u�aB�4ǜ��H���݋���䎂M�q�7з
A�h,��U���Y^(ߠ�����`�WVt�w��@�
�Ǔ)�@N���
�q5��R�^O�SJ�O@�q�?K+r_�gS �Ȩ�N�{����(f�y�ܠV:@�\?�n���`
v��]�i/vLH0`.̡�|:�Tȩ$�e9����
P(ZM�b  H�Y5ˤ2j�

!�p$3Y5�V)�*���;ğ�|����Po���z���{ zx��xS���<u����b�q׺`g���X���ȶ�����_�L��\-��c��HQ�vy6�)���|��(���إ��ߦ�y�X���k��&/���kWt*ǔ�fM���Ǯˍ"^h
��0�WA ���+�S��D͉�L�������ۃ��q��\m��b��%��n܁�.j_DS�6�=嶝&0�� \�u{�`��7Hv���)��<*t3|�U<B�P)��x�����}���\�[�ti���Va3�x�W�ZU�H�fc}q�F�=��L����ӭZa��%Q�#��=
������[K�m㪹#X�XmJ�j%/N+�Ԯ6�DػG>��/�nV�A:���L0Յ^c��E�A�e=	<W�e�
-�?9FbX��?ʙ�ހc�ȟ��rE���������+�a2�I<S��r�<�Fߙ|���^B���$�x�8��eD ��&N}y�����{���ȶ������b?&��
~��+�D+���`p�V[��C	Č|��-��|W��6�ٚq�k$���8���(�*���Bё���NQ��n������,Z�=]��D2F����<�/9�itGO=������������_�ѷ��8�J������D��NR��^��~��ӿmX=p���/����{gҤ(���=����2�q�TDPD؜`gE���fVvu�VgUV%�]�\����,Eo�g|����������$����p4�T��O��vI����R�����_����M�a�{%��@h~�����?��yp���J���E��]��8�y<����jM�SL�^ p<D,��1PG��G>FMz�����t~nP��)�����U	���I��㟋�1M7y�ٮ�汳��Q�ov7'��y�S�Y��꽜���Fs��C���\�vf'f�P��W.f/}�;邘�ސ�)��������lqH���|Ց�.D���n����R�}������p���}|��?����:��Tq�ߓ�'��W
�O����T�������z@�A������s;����Y�o��u�����������?��+�Ž5A��z@�A�k������
����=���.��J�����&�{�g��_pT'�	Gu��[8
$����?*�x�������!���]��E ��0Z(��q?�I���Jx+��n���s�S���9�;�|�:�-�B���,k��i�2�9��~b?3�y{3:ƻg?o����f?���|2������}��}bK�$ؙ���e��J�{��ao?o����2y1��v�N��9�e��VQ.��]k2�4�>6/[-�d����{}"3�ޞ�|��~d���=��I����H�{�5�v�b��ٓ�M���l���=�͹O�rX4W�"�f��9v�S6Ҟ�Ɏ��0Pf��;&�֞��a���v�����i糣�9_tm�T̊~����-i�����m ���D!P�n����C��6���U5H���?p�w%��'����`�S����G����_�&��_�n����?6���� �������B�����f�����_��љ��Y.�,���*��v���[ٯ��?��_���/����{��?t��Pg>y��U4����H�~n�k��H�i�#�GuY��	Ś���$-)�~��Lؘ�Ϥ�������i��SX��=��DC,��z�y&@6D�ПC��$[���V��^���[Ʒ��phisQ�S�S��N	���.Yr)�h3�/�w�LJ2�mo㶘��љb��EhҒ4�WLv�qC+�uj�|qa;6�ksf���o ����� �W��et���!�� ������^}��A��P��0�	.�"p���i��A�#<�}�炀��<�H�p*`�(�p8#��AA������~�������J�A��4Y,�f��P
��Zԩ�,Z�t��m�����C{s���Ώc�TݹȻ#!���l�s��y`���v��P��8%�5U�7��h��f�$����5/�������?��������
��������@B����6�����5����������ǯ���������8m&	����Ƭ�Xg�;��fẋ���l{|�����ձ��)癗��
;�����9���NY>�4�L�a�Q�i�8c�qYR'>6F�d]�E&�*�:��.���������oM p��?������@�����`��`��?�������$����?��Wo�?����������y[�踞r��B��z�������/��e�k3̰�ۚ�� �Ӄ?q �W?����U��U�:U�v��g ��)��CG��^���r�!���=�ؠ�jJz��z��¶�a[.����q�ӧ�68��z�r�υ�^ݛuXf�Y/7(�ĵ��I��%���=�^�v�崤���AJԖt5�������'v�I2���i,)>O���I�K4�7�}��g&��!'��57����H+w��/5)c���	�'��Z���u\?w�&�e 5f3�#��,V��۲�~?�w٢�Si	����G�b�U��z��	_$g�$���r�������
����?�_|��?��]���o������á��
P��땿����%T����Y������p$��U ��a�?�������"`��&*����,�����<΅^H����y��B��<�G�燷� <�$C^�h."<֋`���@!��������x~e������R�9�l=wG$Ƥ>9��Y1zn��tɚ����K��=T��.Q�.酱�hm?�;��Q�͚���t]�}�T�V=��Y\t��1;<v�!��� ���8�nA������������J�x���x��Uߢ�����?KҐ��$�����C�_ET��^�Na�;�����׭�$y�������\��ۏ��r0"T��?���" �Wo����k��y�o�f�6��e;�ҭ�\Yw��AYK��"z/��*iα����=��L������c�wQL��0�&���R-�؛���#��%�h/���o{'Μ�3}�`rV�c��+u6��ḓ�N<�tQoy��������+޴9-3���ui��N
}1I=C��ح��<�z�]�N�|G;��>�ޑ�4I��޲����ڎ�����b���2���]ىh���Y2����j��G���R`&Bs�q��1���8�X8�a3�������^�mk��<U+�;��tlt�^dZ�N��E�۲+�wu{p�oMT���|wT���s�?��$(��Z��?4��
����o���� �������������U) $���s�?����Q��?�Y T@"����� �����a�/������`��W�?f�_Z��S��O�OA�_	(�?����?�_U����-��?�����E���!j���v�'������C��?����<8��?*-���US������?T������_���S �����/�T�&Cj�����������"����G�(��P	���?���� ��5�?XQ#�n����C��6��XQ5H���?P���`�������������������������������������������+�������������!�O���#�?�_ ����%˷������s�?��z�Y���%�'����c�8�����8�}>h�������s����	M3����������K@�_��Cm|���OWg/��s�8��@�6^x�܀e%8����oӦ�.}s����id�'��i�R���ֆ<·�)���p�3�1�;�Y�-O��^˫mÏ�/��5d.Lk1θC��D�O6�v{�Ɉ���8�KO��hI�|k�_C��U��(��a�g}�|��WP��������?����?��?�a`�o�'����>~e�7(�97���h56���8�;�AX����E��Eܩ�K�7���}�Wf٤��y8̵0]+��q�<�<-��Ĺ����(��a���v綸�eЧ�]3*pJ׎�~��UƄ��{A��w�;�+����~���� 
�_0�U0��_0��_���Wo�<` ���_�G���[������������1%O����V�8�Rb����ke���={���S$Wr���_>�������v=�܍�fC9-�=K۝��O�Ac���'����`h�'��K&,>��}�.Ĳ̅}Le�yI{	��Kz�yff��v��&ɗw������ɷ��iI�!]?)Q[��_'.D{sX�Ozb��$��l�ƒ��D���T���1sڧ�~fҎ����Z���ξ�c~!	:�����k�����;��}<
�vo��b*i�iH��m5"L���
"�Mv�)ӈ�{jٌ7;��[��}g~R���0:����?^��9꿕�����?~�)���_	(��`�'�W�G��6�A��Tq�\�i� A�� �'q��K��WA5����vz�GU����?���?��	�������H����u��a���n3M��AR/�{�qW�+|�W��h)����C&_K�E�9�\�K�t�����]<��������þ���BM��|��u��3��%u9��.o�����kK&#q$%��L�&}ͺ�T����q�˻FƮ쁊}5Y��Am�˝*gb<!��k�ZB�ec�#��(�3��Hy�0ٕ�l��6�*��)��r~�|1���-���{ʾy��r��zY)����EE�����'��Y��!?}&B%�RI�8�7���d�7e�E�0�V�=5;�XD�9P�ң���U�91;�"�b*��^j���]���G�	���өp��5F�H&"�v#�)u��T��~��~aH�9�J�U�
���\7�v_Y���7���������oET��8��}��<��y�&=!�»>L��������q�є{���/^�D��
��}��5����J����
��b�͏� �W>��nx�����[���g���ܕ�/���v�n{�]�����^>��K��������� �GpԽ���_%T�����Tq���������Jx+��+o�?�k�O��S���@�\L�N�0��ި��_P��4ԩ���%ذ������a?���������M�y���_�~/i?���~��vǒJ��Ꭼ�v�n�&�zr�CaM��5���N#]�7��+�k?
�]���.-f|<)��V7I�]w|K�a�������y?�W�u*��$��ݐ��˽�v/j����Z�v>�ٲu�q�OL��e9��}b���]k��ږ�ί�sS�n�7��<��OW�����+��D@Qo��ް�f�Ds����8GU�����\kα��z=±�1a���(Fih7X/�����6���Ân��Q�s�\���m��B���\�Q�(3����� �������� ���Ri���\Ʊ�Y&�d�O��Wc��Q*���2��c]0/��8o�˕��!�������������3�����$�h��Z;tȡ"L�U�x {��U��.����5�i���%Q-ȏ��{-���O~`��!J0����b�w��0�i ��_Mja��\��?k����2��m `:(7H���p������T��>��>��؝*�,����ʍv`��޵������MN��?4�\�Q<��˺��u˾�( �&�8rR�fuzl-�c��<�V�x�|�V��--��e�
�ѩ����t傝>]^S�Km��u��Yx!/}NJ鴘��3;��RW�F��J�`�ͪ]���Z\����3�'qY%��0�Y�[�*8E�ۮ�aݲ�/�������j
�/�m��y�G��#�d٨~��Yp|7�7�5^����vH�k���2wEflo�/7u!��VY��4�����	{]�f�ꮮO�C���6^�sOP��^A��)Gku;k
�C�7`֪ȲT��%_sd�aM�=F�Я��R�p��]jSVN��}ßF�~k�o��Ii���
�^��}�<�?�����H�r�_�2%��N��	����	��0������p�% ��o�������2��\ΐ�����-��a�?����������;迷��ϫe}���!�������?���+�w��L	���U�?�9�?���#��SAV���f}� ���������?`����%��/D� ��Ϝ������i '��!-��>����!�#���?����"��1��� K�E!��������ҕ����<�?T�d�\��W�$�� ��������A�����"{@���/����!'��!����C���* �� ���v��������,�_�X���1 ��o���'o�?@�W*��C�V�E������!�������?!K��4�A������������%�*���RB.�_�	70���)U��C�5�B�n�s�T��)�NҺij5�C�V�������~��<���%�:����t�"����Q����K5��&ה��V�7�J���^GB���HM��]��Ok�>uKXU;�)�-Z��^�`*j�p��7��=�n�v�M��M�l��L�E��m�� �Y�M�%�⍹Bb{��
�_QZs��X�Ҹ�I3�4q���Ze�<�����Ī��<�{W7�u��y����3;d���+������C������������>�a`֭p���C��~f�ǩV��vb�C��	�!S/F���Q˲V�6��Bq����K�WF����,ך�oz�V\���`M����#�W�����V���ۺ9�+*'R�c(-�ۅ2v�9��|m��z*�x��^�|��%��Y�������b������/���P��_P��_0��/��Ѐ"�����_	�_���ߣ�k?�v�
}����3�#G�>c�r�O��t��|�UN�f�iK��;lC^�����r�Moܥ0�j�g�qg�������m͝�2G�ŉ��[&��9r*n�J,�6�dݩcj��6W��+�]uW-��ߡ��B�r�&K���9�?�*EdSe�Z�?�_��s� r]��X�M9�;�%�{�}Ԃ�s�Ţ�G�on
J�u�Wj���y���X�#�8{:�����xW���ެ*ծ��qX��S6j��aZ��������t�~�<$���Ԥ݁���.aj�vP�^��|/���S���޺�: �=r�4��o��aW�%&�����G.���Q�� ��������K�?���?��������Ȕ��"�������9��7�`�'d��/Ϻ-�������?y#��SA��\ �GZ��}��1�����������~�������
2��d������_.�����X�1�"����1��H߬�8%��s�����A�pn|l	LoB�M���C�[��Gb���#�k?��
��j���ɇ!��#)�@^Q�;ir�K�o�R�{�@^W��-9a���N�Xcv4O+Ū�1�E��r���+k��^c�6��5֙9u[�Y~�z�IQx��lP6ǧ�ZT,G��QR���h����Q��j�i�p,j9�Д����0�*m��l�թ���cV�.Ol�]��:��L$���z�cc�I��Fih7X/�����6���Ân��Q�s�\���m��B���\�Q�(3��~r��`�?3d��^,�u[�# ��o������̐'�|	� �"���/��S������W��?	�?!s���x�Mq������_.���3B����0 ���E�����[�������T��M�f���q��HiY��d�K����O���"ɺO������ף�L�j ���|�(X�}���U®�媪�4�Q�Y�k���:m�Ɣ�F�"r�ߔ��Q�=�Y�(���Z���[��/*2��_�@�"�?S�$E TЋب��ָ�*��c�����bn�*�|ˌ�h�Ae��XE��2G�uK��Zh���U���Q;
C��fN�n+�l��������_��+d��>-�uK�' ��o���/�7�K��i ?�OVHFWK�iҪ�Vʪ1/aaR�F�N&A`�Aẉ�f��nhmT�1���[�~e��o��	����g��9`fL�!ݲ֘�<愌$�4�[*����d�k+�R4�a�xY��X<n&Z�[E��U����wB���\�iIɑ�Y%Um��s�>���8;J�$�4��Y4L�g�8 >v�E7�����E��������"PY7��#�?��!��?�!s�Z0�n��D����3�?o�[�텨u$�C�RE��:^p-��j�b��NQ�������t�?R��`Kx�W%덝K�P>��1�x�/��	V1Z���c�=�J�S��-i:�2x��6�w\G���\�����G���E%����=2��u �������� �_P��_P��?�������(��/#|K���g����a�=v�%��b��{�����O5 ?S��X rY�e@qi;u%��VU�E�a��bFA�\�TM_ڢ1���X>U�%Z��2i�?����V���y��F]�E���Y��ms��-O��<$�y��F�����U�GS��kl��	��\�俬@n8O�׏ZúW.Kn8Ԕ� �z������]��"D9�����Ul�A��Y�&�Jw�υ�T�}ڷx֋�Ɓ���&,�MO�-O�yf$�\�]�
1d�+kvl�s�V{�h $O�e�WM���^����굙՝�d/M+�_N0~7�ۛ(�h;g5�볿������ ����ݹe����᫡Q��Թ���yg�pT�1���D����G^�>v�A����q9��}���鬌���i���L���]��Bn�ї��O���y������3����r*�7���88�<�~��b��r�p���%������㞇�������N����	�I�?x���Ts\TSA�VNXظ��`����g��7,��U�ĬUw< �>��=U#4�xw�9ɫ�o l��������c:Y�+9��Z!�����}#>����7��ʽ�޽�GA����o|���ۯ}췇=^�_��~W��w�����E��U|V��I�0�g��T>���s���������z�-r�iv^��<��H��������3��1��p~r
��� Ň9��Ƨߘ�V
�s��s]ǵ
����O��ς;��9��lo�q 7��p���T?�$w���C�7����u��H�2�{�;s���zb��=��`��0|�a�[��x�q����~>ŇM�F��_Fa1��Is�F���s㡗N��'�l�k�����x��.>Ŀ1��>v�������(K����E$�
� ���2�_~Rr��W5�"��ڗ����eM              �_
�C2� � 