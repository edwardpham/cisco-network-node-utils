# Copyright (c) 2013-2015 Cisco and/or its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative 'ciscotest'
require_relative '../lib/cisco_node_utils/vxlan_vtep_vni'

include Cisco

# TestVxlanGlobal - Minitest for VxlanGlobal node utility
class TestVxlanVtepVni < CiscoTestCase
  def setup
    super
    config('no feature nv overlay')
    config('feature nv overlay')
  end

  def teardown
    config('no feature nv overlay')
    super
  end

  def test_vnis
    # Test empty case
    assert_empty(VxlanVtepVni.vnis)

    # Create one
    member1 = '5000'
    vni1 = VxlanVtepVni.new('nve1', member1)
    assert_includes(VxlanVtepVni.vnis['nve1'], member1)
    assert_equal(VxlanVtepVni.vnis['nve1'][member1], vni1)

    # Create several
    member2 = '5001-6001'
    member3 = '8888'
    refute_includes(VxlanVtepVni.vnis['nve1'], member2)
    refute_includes(VxlanVtepVni.vnis['nve1'], member3)

    vni2 = VxlanVtepVni.new('nve1', member2)
    vni3 = VxlanVtepVni.new('nve1', member3)
    assert_includes(VxlanVtepVni.vnis['nve1'], member2)
    assert_equal(VxlanVtepVni.vnis['nve1'][member2], vni2)
    assert_includes(VxlanVtepVni.vnis['nve1'], member3)
    assert_equal(VxlanVtepVni.vnis['nve1'][member3], vni3)

    # Destroy one
    vni2.destroy
    refute_includes(VxlanVtepVni.vnis['nve1'], member2)
    refute_equal(VxlanVtepVni.vnis['nve1'][member2], vni2)

    # Destroy all
    vni1.destroy
    vni3.destroy
    assert_empty(VxlanVtepVni.vnis['nve1'])
  end

  def test_ingress_replication
    vni = VxlanVtepVni.new('nve1', '5000')

    # Test non-default values
    vni.ingress_replication = 'static'
    assert_equal('static', vni.ingress_replication)

    vni.ingress_replication = 'bgp'
    assert_equal('bgp', vni.ingress_replication)

    # Test default case
    ir = vni.default_ingress_replication
    vni.ingress_replication = ir
    assert_equal(ir, vni.ingress_replication)
  end

  def test_multicast_group
    vni1 = VxlanVtepVni.new('nve1', '6000')
    vni2 = VxlanVtepVni.new('nve1', '8001-8200')

    # No multicast groups configured
    assert_empty(vni1.multicast_group)

    # Test single multicast group
    vni1.multicast_group = '224.1.1.1'
    assert_equal('224.1.1.1', vni1.multicast_group)

    # Test multicast group range
    vni2.multicast_group = '224.1.1.1 224.1.1.200'
    assert_equal('224.1.1.1 224.1.1.200', vni2.multicast_group)

    # Test default
    vni1.multicast_group = vni1.default_multicast_group
    assert_empty(vni1.multicast_group)
    vni2.multicast_group = vni2.default_multicast_group
    assert_empty(vni2.multicast_group)
  end

  def test_peer_list
    vni = VxlanVtepVni.new('nve1', '6000')

    peer_list = ['1.1.1.1', '2.2.2.2', '3.3.3.3', '4.4.4.4']

    # Test: all peers when current is empty
    should = peer_list.clone
    vni.peer_list = should
    result = vni.peer_list
    assert_equal(should.sort, result.sort,
                 'Test 1. From empty, to all peers')

    # Test: remove half of the peers
    should.shift(2)
    vni.peer_list = should
    result = vni.peer_list
    assert_equal(should.sort, result.sort,
                 'Test 2. Remove half of the peers')

    # Test: restore removed peers
    should = peer_list.clone
    vni.peer_list = should
    result = vni.peer_list
    assert_equal(should.sort, result.sort,
                 'Test 3. Restore removed peers')

    # Test: default
    should = vni.default_peer_list
    vni.peer_list = should
    result = vni.peer_list
    assert_equal(should.sort, result.sort,
                 'Test 4. Default')
  end

  def test_suppress_arp
    vni = VxlanVtepVni.new('nve1', '6000')

    # Test: Check suppress_arp is not configured.
    refute(vni.suppress_arp, 'suppress_arp should be disabled')

    # Test: Enable suppress_arp
    vni.suppress_arp = true
    assert(vni.suppress_arp, 'suppress_arp should be enabled')

    # Test: Default
    vni.suppress_arp = vni.default_suppress_arp
    refute(vni.suppress_arp, 'suppress_arp should be disabled')
  end
end
