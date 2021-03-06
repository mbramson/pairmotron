defmodule Pairmotron.PairRetroTest do
  use Pairmotron.ModelCase
  alias Pairmotron.PairRetro

  @valid_attrs %{subject: "subject", reflection: "reflection", pair_date: Timex.today}
  @invalid_attrs %{}

  describe "changeset" do
    test "changeset with valid attributes" do
      user = insert(:user)
      group = insert(:group, %{owner: user})
      pair = insert(:pair, %{users: [user], group: group})
      attrs = Map.merge(@valid_attrs, %{user_id: user.id,
                                        pair_id: pair.id})
      changeset = PairRetro.changeset(%PairRetro{}, attrs, pair, nil)
      assert changeset.valid?
    end

    test "changeset with a pair that occurred after the pair_date is invalid" do
      user = insert(:user)
      group = insert(:group, %{owner: user})
      pair = insert(:pair, %{users: [user], group: group, year: 2016, week: 1})
      attrs = Map.merge(@valid_attrs, %{pair_date: ~D(2011-01-01),
                                        user_id: user.id,
                                        pair_id: pair.id})
      changeset = PairRetro.changeset(%PairRetro{}, attrs, pair, nil)
      refute changeset.valid?
    end

    test "changeset with a pair_date in the future is invalid" do
      user = insert(:user)
      group = insert(:group, %{owner: user})
      pair = insert(:pair, %{users: [user], group: group})
      attrs = Map.merge(@valid_attrs, %{pair_date: Timex.shift(Timex.today, days: 1),
                                        user_id: user.id,
                                        pair_id: pair.id})
      changeset = PairRetro.changeset(%PairRetro{}, attrs, pair, nil)
      refute changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = PairRetro.changeset(%PairRetro{}, @invalid_attrs, nil, nil)
      refute changeset.valid?
    end

    test "changeset sanitizes subject" do
      user = insert(:user)
      group = insert(:group, %{owner: user})
      pair = insert(:pair, %{users: [user], group: group})
      attrs = Map.merge(@valid_attrs, %{user_id: user.id,
                                        pair_id: pair.id,
                                        subject: "<h1>subject</h1>"})
      changeset = PairRetro.changeset(%PairRetro{}, attrs, pair, nil)
      assert "subject" == changeset.changes.subject
    end

    test "changeset sanitizes reflection" do
      user = insert(:user)
      group = insert(:group, %{owner: user})
      pair = insert(:pair, %{users: [user], group: group})
      attrs = Map.merge(@valid_attrs, %{user_id: user.id,
                                        pair_id: pair.id,
                                        reflection: "<p>reflection</p>"})
      changeset = PairRetro.changeset(%PairRetro{}, attrs, pair, nil)
      assert "reflection" == changeset.changes.reflection
    end
  end

  describe "update changeset" do
    test "changeset with valid attributes" do
      user = insert(:user)
      group = insert(:group, %{owner: user})
      pair = insert(:pair, %{users: [user], group: group})
      attrs = Map.merge(@valid_attrs, %{user_id: user.id,
                                        pair_id: pair.id})
      changeset = PairRetro.update_changeset(%PairRetro{}, attrs, pair, nil)
      assert changeset.valid?
    end

    test "changeset with a pair that occurred after the pair_date is invalid" do
      user = insert(:user)
      group = insert(:group, %{owner: user})
      pair = insert(:pair, %{users: [user], group: group, year: 2016, week: 1})
      attrs = Map.merge(@valid_attrs, %{pair_date: ~D(2011-01-01),
                                        user_id: user.id,
                                        pair_id: pair.id})
      changeset = PairRetro.update_changeset(%PairRetro{}, attrs, pair, nil)
      refute changeset.valid?
    end

    test "changeset with a pair_date in the future is invalid" do
      user = insert(:user)
      group = insert(:group, %{owner: user})
      pair = insert(:pair, %{users: [user], group: group})
      attrs = Map.merge(@valid_attrs, %{pair_date: Timex.shift(Timex.today, days: 1),
                                        user_id: user.id,
                                        pair_id: pair.id})
      changeset = PairRetro.update_changeset(%PairRetro{}, attrs, pair, nil)
      refute changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = PairRetro.update_changeset(%PairRetro{}, @invalid_attrs, nil, nil)
      refute changeset.valid?
    end

    test "changeset sanitizes subject" do
      user = insert(:user)
      group = insert(:group, %{owner: user})
      pair = insert(:pair, %{users: [user], group: group})
      attrs = Map.merge(@valid_attrs, %{user_id: user.id,
                                        pair_id: pair.id,
                                        subject: "<h1>subject</h1>"})
      changeset = PairRetro.update_changeset(%PairRetro{}, attrs, pair, nil)
      assert "subject" == changeset.changes.subject
    end

    test "changeset sanitizes reflection" do
      user = insert(:user)
      group = insert(:group, %{owner: user})
      pair = insert(:pair, %{users: [user], group: group})
      attrs = Map.merge(@valid_attrs, %{user_id: user.id,
                                        pair_id: pair.id,
                                        reflection: "<p>reflection</p>"})
      changeset = PairRetro.update_changeset(%PairRetro{}, attrs, pair, nil)
      assert "reflection" == changeset.changes.reflection
    end
  end

  describe ".retro_for_user_and_week" do
    test "returns the retro for the user for the pair for the given week" do
      user = insert(:user)
      group = insert(:group, %{owner: user})
      pair = insert(:pair, %{users: [user], group: group, year: 2016, week: 25})
      retro = insert(:retro, %{user: user, pair: pair})
      returned_retro = Repo.one(PairRetro.retro_for_user_and_week(user, 2016, 25))
      assert returned_retro.id == retro.id
    end

    test "returns nil when there has been a retro for the user but on the wrong week" do
      user = insert(:user)
      group = insert(:group, %{owner: user})
      pair = insert(:pair, %{users: [user], group: group, year: 2016, week: 25})
      insert(:retro, %{user: user, pair: pair})
      refute Repo.one(PairRetro.retro_for_user_and_week(user, 1999, 10))
    end

    test "returns nil when there has been no retro for the user for the given week" do
      user = insert(:user)
      group = insert(:group, %{owner: user})
      insert(:pair, %{users: [user], group: group, year: 2016, week: 25})
      refute Repo.one(PairRetro.retro_for_user_and_week(user, 2016, 25))
    end

    test "returns nil when there has been no pair for the user for the given week" do
      user = insert(:user)
      group = insert(:group, %{owner: user})
      insert(:pair, %{users: [user], group: group, year: 2016, week: 25})
      refute Repo.one(PairRetro.retro_for_user_and_week(user, 1999, 10))
    end

    test "returns nil when there has been no pair for the user ever" do
      user = insert(:user)
      refute Repo.one(PairRetro.retro_for_user_and_week(user, 2016, 25))
    end
  end

  describe ".retro_for_user_and_pair" do
    test "returns the retro for the user and pair" do
      user = insert(:user)
      pair = insert(:pair, %{users: [user]})
      insert(:retro, %{user: user, pair: pair})

      assert Repo.one(PairRetro.retro_for_user_and_pair(user, pair))
    end

    test "returns the retro for the user and pair out of two pairs and retros" do
      user = insert(:user)
      pair = insert(:pair, %{users: [user]})
      retro = insert(:retro, %{user: user, pair: pair})
      other_pair = insert(:pair, %{users: [user]})
      _other_retro = insert(:retro, %{user: user, pair: other_pair})

      returned_retros = Repo.all(PairRetro.retro_for_user_and_pair(user, pair))
      assert [returned_retro] = returned_retros
      assert returned_retro.id == retro.id
    end

    test "returns the retro for the pair and user out of two users and retros" do
      user = insert(:user)
      other_user = insert(:user)
      pair = insert(:pair, %{users: [user, other_user]})
      retro = insert(:retro, %{user: user, pair: pair})
      _other_retro = insert(:retro, %{user: other_user, pair: pair})

      returned_retros = Repo.all(PairRetro.retro_for_user_and_pair(user, pair))
      assert [returned_retro] = returned_retros
      assert returned_retro.id == retro.id
    end

    test "returns no retro if there are no retros" do
      user = insert(:user)
      pair = insert(:pair, %{users: [user]})

      refute Repo.one(PairRetro.retro_for_user_and_pair(user, pair))
    end
  end

  describe ".users_retros" do
    test "returns nil when there are no retros" do
      user = insert(:user)
      refute Repo.one(PairRetro.users_retros(user))
    end

    test "returns the retro that is assigned to the passed in user" do
      user = insert(:user)
      group = insert(:group, %{owner: user})
      pair = insert(:pair, %{users: [user], group: group})
      retro = insert(:retro, %{user: user, pair: pair})
      returned_retro = Repo.one(PairRetro.users_retros(user))
      assert returned_retro.id == retro.id
    end

    test "does not return a retro for a different user" do
      [retro_user, other_user] = insert_pair(:user)
      group = insert(:group, %{owner: retro_user})
      pair = insert(:pair, %{users: [retro_user], group: group})
      insert(:retro, %{user: retro_user, pair: pair})
      refute Repo.one(PairRetro.users_retros(other_user))
    end
  end
end
